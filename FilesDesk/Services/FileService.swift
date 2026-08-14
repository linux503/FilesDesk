import Foundation
import UniformTypeIdentifiers

enum FileService: Sendable {
    static func collect(
        from urls: [URL],
        includeHidden: Bool,
        includeSubfolders: Bool,
        includeFolders: Bool,
        includeFolderContents: Bool
    ) async throws -> [ImportedFile] {
        var includeFolders = includeFolders
        var includeFolderContents = includeFolderContents
        if !includeFolders && !includeFolderContents {
            includeFolders = true
        }
        var collected: [ImportedFile] = []
        var seen = Set<String>()
        collected.reserveCapacity(256)

        for url in urls {
            try Task.checkCancellation()
            let standardized = url.standardizedFileURL
            let values = try standardized.resourceValues(forKeys: [
                .isDirectoryKey,
                .isPackageKey,
                .isRegularFileKey,
                .isHiddenKey
            ])

            if values.isDirectory == true, values.isPackage != true {
                let folderBookmark = makeBookmark(for: standardized)
                let parentBookmark = makeBookmark(for: standardized.deletingLastPathComponent())
                if includeFolders,
                   let imported = makeImported(
                    url: standardized,
                    values: values,
                    parentBookmark: parentBookmark,
                    fileBookmark: folderBookmark,
                    isDirectory: true
                   ),
                   seen.insert(imported.url.path).inserted {
                    collected.append(imported)
                }
                if includeFolderContents {
                    try await enumerateFolder(
                        at: standardized,
                        includeHidden: includeHidden,
                        includeSubfolders: includeSubfolders,
                        includeFolders: includeFolders,
                        parentBookmark: folderBookmark,
                        into: &collected,
                        seen: &seen
                    )
                }
            } else {
                if let imported = importFile(at: standardized, parentBookmark: nil, includeHidden: includeHidden),
                   seen.insert(imported.url.path).inserted {
                    collected.append(imported)
                }
            }

            if collected.count % 80 == 0 {
                await Task.yield()
            }
        }

        return collected
    }

    private static func enumerateFolder(
        at folder: URL,
        includeHidden: Bool,
        includeSubfolders: Bool,
        includeFolders: Bool,
        parentBookmark: Data?,
        into collected: inout [ImportedFile],
        seen: inout Set<String>
    ) async throws {
        let keys: [URLResourceKey] = [
            .isDirectoryKey,
            .isPackageKey,
            .isRegularFileKey,
            .isHiddenKey,
            .fileSizeKey,
            .contentTypeKey,
            .creationDateKey,
            .contentModificationDateKey,
            .isWritableKey,
            .localizedTypeDescriptionKey
        ]

        guard let enumerator = FileManager.default.enumerator(
            at: folder,
            includingPropertiesForKeys: keys,
            options: includeHidden ? [.skipsPackageDescendants] : [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            return
        }

        var count = 0
        while let next = enumerator.nextObject() as? URL {
            try Task.checkCancellation()
            let values = try? next.resourceValues(forKeys: Set(keys))
            let isDirectory = values?.isDirectory == true && values?.isPackage != true

            if isDirectory {
                if includeFolders,
                   !shouldSkip(next, includeHidden: includeHidden, values: values),
                   let imported = makeImported(
                    url: next.standardizedFileURL,
                    values: values,
                    parentBookmark: parentBookmark,
                    fileBookmark: makeBookmark(for: next),
                    isDirectory: true
                   ),
                   seen.insert(imported.url.path).inserted {
                    collected.append(imported)
                }
                if !includeSubfolders {
                    enumerator.skipDescendants()
                }
                continue
            }

            if shouldSkip(next, includeHidden: includeHidden, values: values) {
                continue
            }

            if let imported = makeImported(
                url: next.standardizedFileURL,
                values: values,
                parentBookmark: parentBookmark,
                fileBookmark: nil,
                isDirectory: false
            ), seen.insert(imported.url.path).inserted {
                collected.append(imported)
            }

            count += 1
            if count % 80 == 0 {
                await Task.yield()
            }
        }
    }

    private static func importFile(at url: URL, parentBookmark: Data?, includeHidden: Bool) -> ImportedFile? {
        let keys: Set<URLResourceKey> = [
            .isDirectoryKey,
            .isPackageKey,
            .isHiddenKey,
            .fileSizeKey,
            .contentTypeKey,
            .creationDateKey,
            .contentModificationDateKey,
            .isWritableKey,
            .localizedTypeDescriptionKey
        ]
        let values = try? url.resourceValues(forKeys: keys)
        if shouldSkip(url, includeHidden: includeHidden, values: values) {
            return nil
        }
        return makeImported(
            url: url,
            values: values,
            parentBookmark: parentBookmark,
            fileBookmark: makeBookmark(for: url),
            isDirectory: values?.isDirectory == true && values?.isPackage != true
        )
    }

    private static func makeImported(
        url: URL,
        values: URLResourceValues?,
        parentBookmark: Data?,
        fileBookmark: Data?,
        isDirectory: Bool
    ) -> ImportedFile? {
        let name = url.lastPathComponent
        guard !name.isEmpty else { return nil }

        let directory = url.deletingLastPathComponent()
        let type = isDirectory
            ? UTType.folder
            : (values?.contentType ?? UTType(filenameExtension: url.pathExtension) ?? .data)
        let parentWritable = FileManager.default.isWritableFile(atPath: directory.path)
        let writable = parentWritable || parentBookmark != nil || (isDirectory && fileBookmark != nil)

        return ImportedFile(
            url: url,
            name: name,
            directoryURL: directory,
            fileSize: isDirectory ? 0 : Int64(values?.fileSize ?? 0),
            typeIdentifier: type.identifier,
            typeName: isDirectory ? "文件夹" : (values?.localizedTypeDescription ?? type.localizedDescription ?? url.pathExtension.uppercased()),
            createdAt: values?.creationDate ?? .now,
            modifiedAt: values?.contentModificationDate ?? .now,
            bookmark: fileBookmark,
            parentBookmark: parentBookmark,
            directoryWritable: writable,
            hasSecurityAccess: true,
            isDirectory: isDirectory
        )
    }

    private static func shouldSkip(_ url: URL, includeHidden: Bool, values: URLResourceValues?) -> Bool {
        let name = url.lastPathComponent
        if name == ".DS_Store" || name.hasPrefix("._") || name == "__MACOSX" {
            return true
        }
        if name.hasPrefix(".filesdesk-temp-") {
            return true
        }
        if !includeHidden, values?.isHidden == true || name.hasPrefix(".") {
            return true
        }
        return false
    }

    static func makeBookmark(for url: URL) -> Data? {
        try? url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
    }

    static func resolveBookmark(_ data: Data) -> URL? {
        var stale = false
        return try? URL(
            resolvingBookmarkData: data,
            options: [.withSecurityScope],
            relativeTo: nil,
            bookmarkDataIsStale: &stale
        )
    }
}
