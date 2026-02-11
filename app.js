const tableBody = document.querySelector("#dataTable tbody");
const form = document.querySelector("#addForm");
const searchInput = document.getElementById("search");
const rowCount = document.getElementById("rowCount");
const resetFormBtn = document.getElementById("resetForm");
const clearSearchBtn = document.getElementById("clearSearch");
const formError = document.getElementById("formError");
const excelInput = document.getElementById("excelFile");
const exportExcelBtn = document.getElementById("exportExcel");
const clearAllBtn = document.getElementById("clearAll");
const exportJSONBtn = document.getElementById("exportJSONBtn");


// =======================
// Columns
// =======================
const columns = [
  "References",
  "InChIKey",
  "Superclass",
  "Class",
  "Subclass",
  "Parent Level 1",
  "Name Normalized",
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
  "botanical_source3"
];

let data = [];


// =======================
// Save LocalStorage
// =======================
function saveData() {
  localStorage.setItem("propolisData", JSON.stringify(data));
}


// =======================
// ✅ Load from JSON or LocalStorage
// =======================
async function loadData() {

  try {

    // tenta carregar data.json do GitHub
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

    console.warn("data.json não encontrado, usando localStorage");

  }

  // fallback para localStorage
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

  filtered.forEach((row, index) => {

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


    const tdRemove = document.createElement("td");

    const btn = document.createElement("button");

    btn.textContent = "✕";

    btn.onclick = () => removeRow(index);

    tdRemove.appendChild(btn);

    tr.appendChild(tdRemove);

    tableBody.appendChild(tr);

  });

  rowCount.textContent = `${filtered.length} row(s)`;

}


// =======================
// Add record
// =======================
form.addEventListener("submit", e => {

  e.preventDefault();

  const required = [
    form.elements["Name Normalized"],
    form.elements["IUPAC Name"],
    form.elements["Molecular Weight"],
    form.elements["Canonical SMILES"]
  ];

  if (required.filter(f => f.value.trim()).length < 2) {

    formError.textContent = "Please fill at least 2 required fields.";

    return;

  }

  formError.textContent = "";

  const formData = new FormData(form);

  const row = {};

  columns.forEach(col => {

    row[col] = col === "PubChem"
      ? ""
      : (formData.get(col)?.trim() || "");

  });

  const key = makeKey(row);

  const index = data.findIndex(r => makeKey(r) === key);

  if (index >= 0)
    data[index] = row;
  else
    data.push(row);

  saveData();

  renderTable(searchInput.value);

  form.reset();

});


// =======================
// Remove row
// =======================
function removeRow(index) {

  data.splice(index, 1);

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
// Import Excel
// =======================
excelInput.addEventListener("change", e => {

  const file = e.target.files[0];

  if (!file) return;

  const reader = new FileReader();

  reader.onload = e => {

    const workbook = XLSX.read(
      new Uint8Array(e.target.result),
      { type: "array" }
    );

    const sheet = workbook.Sheets[workbook.SheetNames[0]];

    const imported = XLSX.utils.sheet_to_json(sheet);

    imported.forEach(row => {

      const newRow = {};

      columns.forEach(col => {

        newRow[col] = col === "PubChem"
          ? ""
          : (row[col]?.toString().trim() || "");

      });

      const key = makeKey(newRow);

      const index = data.findIndex(r => makeKey(r) === key);

      if (index >= 0)
        data[index] = newRow;
      else
        data.push(newRow);

    });

    saveData();

    renderTable(searchInput.value);

  };

  reader.readAsArrayBuffer(file);

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
