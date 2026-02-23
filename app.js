const tableBody = document.querySelector("#dataTable tbody");
const searchInput = document.getElementById("search");
const rowCount = document.getElementById("rowCount");
const clearSearchBtn = document.getElementById("clearSearch");
const exportExcelBtn = document.getElementById("exportExcel");
const clearAllBtn = document.getElementById("clearAll");
const exportJSONBtn = document.getElementById("exportJSONBtn");

// =======================
// Columns
// =======================
const columns = [
  "Name Normalized",
  "InChIKey",
  "Superclass",
  "Class",
  "Subclass",
  "Parent Level 1",
  "CID",
  "Canonical SMILES",
  "Molecular Formula",
  "Molecular Weight",
  "IUPAC Name",
  "PubChem",
  "name",
  "articleID",
  "publication_year",
  "mol_formula",
  "continent",
  "country",
  "region",
  "estate/province",
  "city",
  "coordinates",
  "altitude(m)",
  "month_collection",
  "year_collection",
  "sample_type",
  "bee_specie",
  "color",
  "consitency",
  "climate-biome_zone",
  "Methods_sample",
  "methods_compounds",
  "botanical_source1",
  "local_flora1",
  "botanical_source2",
  "botanical_source3",
  "References"
];

let data = [];


// =======================
// Save LocalStorage
// =======================
function saveData() {
  localStorage.setItem("propolisData", JSON.stringify(data));
}


// =======================
// Load from JSON or LocalStorage
// =======================
async function loadData() {

  try {
    const response = await fetch("data.json");

    if (response.ok) {
      const jsonData = await response.json();

      if (jsonData.length > 0) {
        data = jsonData;
        saveData();
        return;
      }
    }

  } catch (error) {
    console.warn("data.json not found, using localStorage");
  }

  const stored = localStorage.getItem("propolisData");
  data = stored ? JSON.parse(stored) : [];

}


// =======================
// Export JSON
// =======================
function exportJSON() {

  const blob = new Blob(
    [JSON.stringify(data, null, 2)],
    { type: "application/json" }
  );

  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = "data.json";

  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);

}


// =======================
// Unique key
// =======================
function makeKey(row) {
  return `${(row.InChIKey || "").trim()}__${(row.CID || "").trim()}`;
}


// =======================
// Filter
// =======================
function getFilteredData(filter = "") {

  if (!filter.trim()) return data;

  const term = filter.toLowerCase();

  return data.filter(row =>
    columns.some(col =>
      col !== "PubChem" &&
      String(row[col] || "").toLowerCase().includes(term)
    )
  );

}


// =======================
// Render table
// =======================
function renderTable(filter = "") {

  tableBody.innerHTML = "";

  const filtered = getFilteredData(filter);

  filtered.forEach((row) => {

    const tr = document.createElement("tr");

    columns.forEach(col => {

      const td = document.createElement("td");

      if (col === "PubChem" && row.CID) {

        const a = document.createElement("a");
        a.href = `https://pubchem.ncbi.nlm.nih.gov/compound/${row.CID}`;
        a.target = "_blank";
        a.textContent = "PubChem";
        td.appendChild(a);

      }

      else if (col === "References" && row[col]) {

        td.innerHTML = row[col]
          .split(",")
          .map(r => r.trim())
          .join(",<br>");

      }

      else {

        td.textContent = row[col] || "";

      }

      tr.appendChild(td);

    });

    // Remove button
    const tdRemove = document.createElement("td");
    const btn = document.createElement("button");

    btn.textContent = "✕";
    btn.onclick = () => removeRow(row);

    tdRemove.appendChild(btn);
    tr.appendChild(tdRemove);

    tableBody.appendChild(tr);

  });

  rowCount.textContent = `${filtered.length} row(s)`;

}


// =======================
// Remove row
// =======================
function removeRow(rowToRemove) {

  data = data.filter(row =>
    makeKey(row) !== makeKey(rowToRemove)
  );

  saveData();
  renderTable(searchInput.value);

}


// =======================
// Clear all
// =======================
clearAllBtn.addEventListener("click", () => {

  if (!confirm("Delete ALL data?")) return;

  data = [];
  localStorage.removeItem("propolisData");
  renderTable();

});


// =======================
// Search
// =======================
searchInput.addEventListener("input", () =>
  renderTable(searchInput.value)
);

clearSearchBtn.addEventListener("click", () => {

  searchInput.value = "";
  renderTable();

});


// =======================
// Export Excel
// =======================
exportExcelBtn.addEventListener("click", () => {

  const worksheet = XLSX.utils.json_to_sheet(data);
  const workbook = XLSX.utils.book_new();

  XLSX.utils.book_append_sheet(workbook, worksheet, "PropolisData");
  XLSX.writeFile(workbook, "propolis_data.xlsx");

});


// =======================
// Export JSON button
// =======================
if (exportJSONBtn) {
  exportJSONBtn.addEventListener("click", exportJSON);
}


// =======================
// Init
// =======================
(async () => {

  await loadData();
  renderTable();

})();
