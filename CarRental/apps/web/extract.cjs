const fs = require('fs');
const path = require('path');

// Read the files
const fleetContent = fs.readFileSync(path.join(__dirname, 'src', 'data', 'fleet.ts'), 'utf-8');
const faqContent = fs.readFileSync(path.join(__dirname, 'src', 'data', 'faq.ts'), 'utf-8');
const testimonialsContent = fs.readFileSync(path.join(__dirname, 'src', 'data', 'testimonials.ts'), 'utf-8');

function extractImports(content) {
    const imports = {};
    const regex = /import\s+([a-zA-Z0-9_]+)\s+from\s+['"]([^'"]+)['"]/g;
    let match;
    while ((match = regex.exec(content)) !== null) {
        const varName = match[1];
        let importPath = match[2];
        // Only keep the filename for assets
        if (importPath.includes('assets/cars/')) {
            imports[varName] = path.basename(importPath);
        }
    }
    return imports;
}

const fleetImports = extractImports(fleetContent);

// A very hacky but effective way to parse the TS data into JSON without a full AST
// We will replace variable references with strings or inline them, then evaluate it.

function sanitizeTS(content, imports) {
    let sanitized = content;
    
    // Remove all import statements
    sanitized = sanitized.replace(/import\s+.*?;?\n/g, '');
    
    sanitized = sanitized.replace(/export\s+const\s+[A-Z_]+\s*:\s*[a-zA-Z_\[\]]+\s*=/g, 'const DATA =');
    
    // Replace standard constants
    sanitized = sanitized.replace(/KMS_DAILY/g, '300');
    sanitized = sanitized.replace(/KMS_WEEKLY/g, '200');
    sanitized = sanitized.replace(/KMS_MONTHLY/g, '4000');
    sanitized = sanitized.replace(/SALIK/g, '1');
    sanitized = sanitized.replace(/VAT/g, '5');
    
    // Replace imports with strings
    for (const [varName, filePath] of Object.entries(imports)) {
        // Replace exact word matches
        const regex = new RegExp(`\\b${varName}\\b`, 'g');
        sanitized = sanitized.replace(regex, `"${filePath}"`);
    }
    
    return sanitized;
}

try {
    const sanitizedFleet = sanitizeTS(fleetContent, fleetImports);
    
    // Evaluate the fleet data
    let fleetData;
    // Create a mock context to eval
    const evalScript = `
        let STANDARD_INCLUDES = [];
        let STANDARD_FAQS = [];
        ${sanitizedFleet}
        return DATA;
    `;
    
    // Hacky way to handle arrays defined before the main array
    const extractArray = (name, content) => {
        const regex = new RegExp(`const\\s+${name}\\s*=\\s*(\\[[\\s\\S]*?\\]);`);
        const match = content.match(regex);
        if (match) {
            return match[1];
        }
        return "[]";
    };
    
    const stdIncludes = extractArray('STANDARD_INCLUDES', sanitizedFleet);
    const stdFaqs = extractArray('STANDARD_FAQS', sanitizedFleet);
    
    // Final script to eval
    const finalScript = `
        const STANDARD_INCLUDES = ${stdIncludes};
        const STANDARD_FAQS = ${stdFaqs};
        let DATA;
        ${sanitizedFleet.replace(/const\s+STANDARD_INCLUDES[\s\S]*?\];/, '')
                        .replace(/const\s+STANDARD_FAQS[\s\S]*?\];/, '')}
        DATA;
    `;
    
    fleetData = eval(finalScript);
    
    fs.writeFileSync(path.join(__dirname, '..', 'data', 'seeds', 'extracted_fleet.json'), JSON.stringify(fleetData, null, 2));
    console.log('Successfully extracted fleet data to JSON.');
} catch (e) {
    console.error('Error parsing fleet data:', e);
}
