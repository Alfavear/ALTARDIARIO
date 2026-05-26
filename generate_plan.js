const XLSX = require('xlsx');
const fs = require('fs');
const path = require('path');

const workbook = XLSX.readFile(path.join(__dirname, 'Plan Anual de Lectura biblica Trastornadores.xlsx'));

const monthNames = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];

const result = {};
let dayCount = 0;

monthNames.forEach((monthName, monthIdx) => {
  const sheet = workbook.Sheets[monthName];
  if (!sheet) {
    console.error(`Sheet "${monthName}" not found!`);
    return;
  }

  const data = XLSX.utils.sheet_to_json(sheet, { header: 1, defval: '' });

  // Find where "Domingo" header row is to determine the offset
  let headerRowIdx = -1;
  for (let i = 0; i < Math.min(5, data.length); i++) {
    if (data[i] && data[i][0] === 'Domingo') {
      headerRowIdx = i;
      break;
    }
  }
  
  if (headerRowIdx === -1) {
    console.error(`Could not find header row for ${monthName}`);
    return;
  }

  // Day/reading pairs start right after the header row
  // Pairs: (headerRowIdx+1, headerRowIdx+2), (headerRowIdx+3, headerRowIdx+4), etc.
  let monthDayCount = 0;
  for (let pairStart = headerRowIdx + 1; pairStart < data.length - 1; pairStart += 2) {
    const dayRow = data[pairStart];
    const readingRow = data[pairStart + 1];
    if (!dayRow || !readingRow) continue;

    for (let col = 0; col < 7; col++) {
      const dayNum = dayRow[col];
      const reading = readingRow[col];

      if (typeof dayNum === 'number' && dayNum >= 1 && dayNum <= 31) {
        const readingText = (typeof reading === 'string') ? reading.trim() : '';
        if (readingText) {
          const month = (monthIdx + 1).toString().padStart(2, '0');
          const day = dayNum.toString().padStart(2, '0');
          const dateKey = `${month}-${day}`;
          result[dateKey] = readingText;
          dayCount++;
          monthDayCount++;
        }
      }
    }
  }
  console.log(`${monthName}: ${monthDayCount} days extracted`);
});

console.log(`\nTotal days extracted: ${dayCount}`);

// Sort by date
const sortedKeys = Object.keys(result).sort();

// Write calendar-based format (MM-DD -> reading)
const outputDir = path.join(__dirname, 'assets');
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

fs.writeFileSync(
  path.join(outputDir, 'plan_lectura.json'),
  JSON.stringify(result, null, 2),
  'utf8'
);

// Print first and last entries
console.log('\n=== First 10 entries ===');
sortedKeys.slice(0, 10).forEach(k => console.log(`${k}: ${result[k]}`));
console.log('\n=== Last 5 entries ===');
sortedKeys.slice(-5).forEach(k => console.log(`${k}: ${result[k]}`));

console.log(`\nDone! File written to assets/plan_lectura.json`);
