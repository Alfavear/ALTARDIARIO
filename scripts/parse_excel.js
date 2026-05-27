const XLSX = require('xlsx');
const fs = require('fs');
const path = require('path');

const workbook = XLSX.readFile(path.join(__dirname, 'Plan Anual de Lectura biblica Trastornadores.xlsx'));

// Print all sheet names
console.log("=== SHEET NAMES ===");
console.log(workbook.SheetNames);

// For each sheet, show the first 10 rows of data
workbook.SheetNames.forEach(name => {
  console.log(`\n=== SHEET: ${name} ===`);
  const sheet = workbook.Sheets[name];
  const range = XLSX.utils.decode_range(sheet['!ref'] || 'A1');
  console.log(`Range: ${sheet['!ref']}`);
  
  // Show first 15 rows to understand structure
  const data = XLSX.utils.sheet_to_json(sheet, { header: 1, defval: '' });
  for (let i = 0; i < Math.min(15, data.length); i++) {
    console.log(`Row ${i}: ${JSON.stringify(data[i])}`);
  }
  console.log(`... Total rows: ${data.length}`);
});
