const fs = require('fs');
const path = require('path');

console.log('--- STARTING CONFIGURATION VALIDATION LOGS ---');

const errors = [];
const warnings = [];

// 1. Verify firebase.json and ci_deploy.yml hosting mismatch
try {
  const firebaseJsonPath = path.join(__dirname, '../firebase.json');
  const firebaseJson = JSON.parse(fs.readFileSync(firebaseJsonPath, 'utf8'));
  
  const ciDeployPath = path.join(__dirname, '../.github/workflows/ci_deploy.yml');
  const ciDeploy = fs.readFileSync(ciDeployPath, 'utf8');

  if (ciDeploy.includes('hosting') && !firebaseJson.hosting) {
    errors.push('CRITICAL: .github/workflows/ci_deploy.yml deploys "hosting", but "hosting" is not configured in firebase.json! This deployment will fail.');
  } else {
    console.log('✓ Firebase Hosting configuration alignment checked.');
  }

  if (!firebaseJson.emulators) {
    warnings.push('WARNING: No "emulators" configured in firebase.json, but docs/RELEASE.md and docs/TESTING.md describe running them.');
  }
} catch (e) {
  warnings.push(`Could not fully validate Firebase settings: ${e.message}`);
}

// 2. Verify Flutter SDK mismatch in workflows and pubspec.yaml
try {
  const pubspecPath = path.join(__dirname, '../padeleiro_app/pubspec.yaml');
  const pubspec = fs.readFileSync(pubspecPath, 'utf8');
  const sdkMatch = pubspec.match(/sdk:\s*['"]?([^\s'"]+)['"]?/);
  
  const ciDeployPath = path.join(__dirname, '../.github/workflows/ci_deploy.yml');
  const ciDeploy = fs.readFileSync(ciDeployPath, 'utf8');
  
  const flutterTestPath = path.join(__dirname, '../.github/workflows/flutter_test.yml');
  const flutterTest = fs.readFileSync(flutterTestPath, 'utf8');

  console.log(`- pubspec.yaml Dart SDK constraint: ${sdkMatch ? sdkMatch[1] : 'Not found'}`);
  
  const deployFlutterVer = ciDeploy.match(/flutter-version:\s*['"]?([^\s'"]+)['"]?/);
  const testFlutterVer = flutterTest.match(/flutter-version:\s*['"]?([^\s'"]+)['"]?/);

  console.log(`- ci_deploy.yml Flutter version: ${deployFlutterVer ? deployFlutterVer[1] : 'Not found'}`);
  console.log(`- flutter_test.yml Flutter version: ${testFlutterVer ? testFlutterVer[1] : 'Not found'}`);

  if (sdkMatch && sdkMatch[1].includes('^3.12.0')) {
    if (deployFlutterVer && deployFlutterVer[1] === '3.13.0') {
      errors.push('CRITICAL: Flutter SDK version 3.13.0 uses Dart SDK 3.1.x, which does not satisfy the pubspec.yaml constraint ^3.12.0. CI build will fail.');
    }
  }
} catch (e) {
  warnings.push(`Could not fully validate Flutter/Dart versions: ${e.message}`);
}

// 3. Verify Branch Protection Check Mismatch
try {
  const branchProtectionPath = path.join(__dirname, '../.github/workflows/set_branch_protection.yml');
  const branchProt = fs.readFileSync(branchProtectionPath, 'utf8');
  
  const ciDeployPath = path.join(__dirname, '../.github/workflows/ci_deploy.yml');
  const ciDeploy = fs.readFileSync(ciDeployPath, 'utf8');

  const contextMatch = branchProt.match(/contexts\s*=\s*\[\s*['"]([^'"]+)['"]/);
  if (contextMatch) {
    const requiredContext = contextMatch[1];
    console.log(`- Required Status Check Context in set_branch_protection.yml: "${requiredContext}"`);
    
    // Check if CI Deploy runs on PR
    if (!ciDeploy.includes('pull_request:')) {
      errors.push(`CRITICAL: Branch protection requires "${requiredContext}" to pass before merging, but .github/workflows/ci_deploy.yml (which runs this check) is NOT configured to run on pull requests! This will permanently deadlock pull requests.`);
    }
  }
} catch (e) {
  warnings.push(`Could not fully validate Branch Protection contexts: ${e.message}`);
}

// 4. Verify Node.js version mismatch
try {
  const packageJsonPath = path.join(__dirname, '../functions/package.json');
  const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
  
  const ciDeployPath = path.join(__dirname, '../.github/workflows/ci_deploy.yml');
  const ciDeploy = fs.readFileSync(ciDeployPath, 'utf8');

  const nodeVerDeploy = ciDeploy.match(/node-version:\s*['"]?(\d+)['"]?/);
  const nodeVerFunc = packageJson.engines ? packageJson.engines.node : null;

  console.log(`- Functions package.json target Node: ${nodeVerFunc}`);
  console.log(`- ci_deploy.yml configured Node: ${nodeVerDeploy ? nodeVerDeploy[1] : 'Not found'}`);

  if (nodeVerDeploy && nodeVerFunc && nodeVerDeploy[1] !== nodeVerFunc) {
    warnings.push(`WARNING: Node.js version mismatch. Functions package.json targets Node ${nodeVerFunc}, but CI deploy uses Node ${nodeVerDeploy[1]}.`);
  }
} catch (e) {
  warnings.push(`Could not fully validate Node.js engine versions: ${e.message}`);
}

console.log('\n--- RESULTS OF CONFIGURATION VALIDATION ---');
if (errors.length > 0) {
  console.log('🔴 ERRORS FOUND:');
  errors.forEach(err => console.log(`  - ${err}`));
} else {
  console.log('💚 NO CRITICAL ERRORS FOUND');
}

if (warnings.length > 0) {
  console.log('⚠️ WARNINGS FOUND:');
  warnings.forEach(warn => console.log(`  - ${warn}`));
}

console.log('--- END OF VALIDATION LOGS ---');
