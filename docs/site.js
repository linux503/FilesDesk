const REPO = "linux503/FilesDesk";

async function latestRelease() {
  const nodes = document.querySelectorAll("[data-download]");
  if (!nodes.length) return;
  try {
    const response = await fetch(`https://api.github.com/repos/${REPO}/releases/latest`);
    if (!response.ok) throw new Error("no release");
    const data = await response.json();
    const zip = (data.assets || []).find((asset) => asset.name.endsWith(".zip"));
    const href = zip ? zip.browser_download_url : data.html_url;
    nodes.forEach((node) => {
      node.href = href;
      if (node.dataset.version) node.dataset.version = data.tag_name;
    });
    document.querySelectorAll("[data-latest-tag]").forEach((node) => {
      node.textContent = data.tag_name.replace(/^v/, "");
    });
  } catch (error) {
    nodes.forEach((node) => {
      node.href = `https://github.com/${REPO}/releases`;
    });
  }
}

latestRelease();
