const fs = require('fs');
function extractPaths(file) {
  const content = fs.readFileSync(file, 'utf-8');
  let result = {};
  let currentSlug = null;
  const lines = content.split('\n');
  for (let line of lines) {
    if (line.includes('slug: .')) {
      currentSlug = line.match(/slug: \.([a-zA-Z0-9]+)/)[1];
      result[currentSlug] = [];
    } else if ((line.includes('"M') || line.includes('"m')) && currentSlug) {
      let match = line.match(/"([^"]+)"/);
      if (match) {
        result[currentSlug].push(match[1]);
      }
    }
  }
  return result;
}

const maleFront = extractPaths('../MuscleMap/Sources/MuscleMap/Data/MaleFrontPaths.swift');
const maleBack = extractPaths('../MuscleMap/Sources/MuscleMap/Data/MaleBackPaths.swift');
const femaleFront = extractPaths('../MuscleMap/Sources/MuscleMap/Data/FemaleFrontPaths.swift');
const femaleBack = extractPaths('../MuscleMap/Sources/MuscleMap/Data/FemaleBackPaths.swift');

const flutterCode = `
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class MusclePaths {
  static final Map<String, List<String>> maleFront = ${JSON.stringify(maleFront)};
  static final Map<String, List<String>> maleBack = ${JSON.stringify(maleBack)};
  static final Map<String, List<String>> femaleFront = ${JSON.stringify(femaleFront)};
  static final Map<String, List<String>> femaleBack = ${JSON.stringify(femaleBack)};
}
`;

fs.writeFileSync('lib/muscle_paths.dart', flutterCode);
console.log('Saved to lib/muscle_paths.dart');
