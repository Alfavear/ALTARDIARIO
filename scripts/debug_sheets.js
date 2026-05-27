const XLSX = require('xlsx');
const path = require('path');

const workbook = XLSX.readFile(path.join(__dirname, 'Plan Anual de Lectura biblica Trastornadores.xlsx'));

console.log("All sheets:", workbook.SheetNames);

// Check first 4 months in detail
['Enero', 'Febrero', 'Marzo', 'Abril'].forEach(name => {
  const sheet = workbook.Sheets[name];
  if (!sheet) {
    console.log(`\n!!! Sheet "${name}" NOT FOUND !!!`);
    // Try variations
    workbook.SheetNames.forEach(s => {
      if (s.toLowerCase().includes(name.toLowerCase().substring(0,3))) {
        console.log(`  Possible match: "${s}"`);
      }
    });
    return;
  }
  const data = XLSX.utils.sheet_to_json(sheet, { header: 1, defval: '' });
  console.log(`\n=== ${name} ===`);
  for (let i = 0; i < Math.min(15, data.length); i++) {
    console.log(`Row ${i}: ${JSON.stringify(data[i])}`);
  }
});
