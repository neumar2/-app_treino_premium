const https = require('https');
const fs = require('fs');

// Tentar pegar o JSON real com os GIFs de um repositório aberto
const urlsToTry = [
  'https://raw.githubusercontent.com/Glowupp-app/open-exercisedb/main/exercises.json'
];

const equipmentMap = {
  'barbell': 'Barra',
  'dumbbell': 'Halter',
  'cable': 'Polia/Cabo',
  'machine': 'Máquina',
  'body weight': 'Peso do Corpo',
  'bodyweight': 'Peso do Corpo',
  'body only': 'Peso do Corpo',
  'kettlebell': 'Kettlebell',
  'band': 'Elástico',
  'bands': 'Elástico',
  'medicine ball': 'Bola Medicinal',
  'exercise ball': 'Bola Suíça',
  'foam roll': 'Rolo de Espuma',
  'ez barbell': 'Barra W',
  'e-z curl bar': 'Barra W',
  'smith machine': 'Máquina Smith',
  'roller': 'Rolo Abdominal',
  'trap bar': 'Barra Hexagonal',
  'rope': 'Corda',
  'other': 'Outro'
};

const muscleMap = {
  'chest': 'peito',
  'back': 'costas',
  'shoulders': 'ombros',
  'upper arms': 'biceps',
  'lower arms': 'triceps',
  'waist': 'abdominals',
  'upper legs': 'quadriceps',
  'lower legs': 'calves',
  'neck': 'neck',
  'cardio': 'cardio',
  'pelvis': 'glutes'
};

const targetMap = {
  'abs': 'abdominals',
  'abductors': 'adductors',
  'adductors': 'adductors',
  'biceps': 'biceps',
  'calves': 'calves',
  'cardiovascular system': 'cardio',
  'delts': 'shoulders',
  'forearms': 'forearms',
  'glutes': 'glutes',
  'hamstrings': 'hamstrings',
  'lats': 'lats',
  'levator scapulae': 'upperBack',
  'pectorals': 'chest',
  'quads': 'quadriceps',
  'serratus anterior': 'obliques',
  'spine': 'lowerBack',
  'traps': 'trapezius',
  'triceps': 'triceps',
  'upper back': 'upperBack'
};

const nameDictionary = {
  'Barbell': 'com Barra',
  'Dumbbell': 'com Halteres',
  'Cable': 'na Polia',
  'Bench Press': 'Supino',
  'Incline': 'Inclinado',
  'Decline': 'Declinado',
  'Squat': 'Agachamento',
  'Deadlift': 'Levantamento Terra',
  'Curl': 'Rosca',
  'Extension': 'Extensão',
  'Flyes': 'Crucifixo',
  'Fly': 'Voador',
  'Row': 'Remada',
  'Pulldown': 'Puxada',
  'Pushdown': 'Tríceps Pulley',
  'Push-Up': 'Flexão',
  'Pull-Up': 'Barra Fixa',
  'Lunge': 'Avanço',
  'Crunch': 'Abdominal',
  'Lateral Raise': 'Elevação Lateral',
  'Front Raise': 'Elevação Frontal',
  'Leg Press': 'Leg Press',
  'Calf Raise': 'Elevação de Panturrilha',
  'Seated': 'Sentado',
  'Standing': 'em Pé',
  'Lying': 'Deitado',
  'Overhead': 'Acima da Cabeça',
  'Reverse': 'Invertido'
};

function translateName(name) {
  let newName = name.replace(/\b([a-z])/g, char => char.toUpperCase()); // title case
  for (const [eng, pt] of Object.entries(nameDictionary)) {
    const regex = new RegExp(`\\b${eng}\\b`, 'gi');
    newName = newName.replace(regex, pt);
  }
  return newName;
}

function fetchJson(url) {
  return new Promise((resolve, reject) => {
    https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' } }, (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        return fetchJson(res.headers.location).then(resolve).catch(reject);
      }
      if (res.statusCode !== 200) {
        return reject(new Error(`Failed with status code: ${res.statusCode} for ${url}`));
      }
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

async function start() {
  let rawData = null;
  for (const url of urlsToTry) {
    try {
      console.log(`Tentando baixar de: ${url}`);
      rawData = await fetchJson(url);
      if (rawData && rawData.length > 0) {
        console.log(`Sucesso! Encontrados ${rawData.length} exercícios.`);
        break;
      }
    } catch (e) {
      console.log(`Falhou: ${e.message}`);
    }
  }

  if (!rawData) {
    console.log("Não conseguimos baixar. Como fallback, podemos recriar o JSON apontando para APIs estáticas conhecidas.");
    // Criaremos um mock de 1 exercício se tudo falhar, mas deve funcionar.
    return;
  }

  const translated = rawData.map(ex => {
    const id = ex.id;
    const name = translateName(ex.name || '');
    
    let rawEq = Array.isArray(ex.equipment) ? ex.equipment[0] : ex.equipment;
    let rawTarget = Array.isArray(ex.target) ? ex.target[0] : ex.target;
    let rawBodyPart = Array.isArray(ex.bodyPart) ? ex.bodyPart[0] : ex.bodyPart;

    rawEq = String(rawEq || 'body only');
    rawTarget = String(rawTarget || '');
    rawBodyPart = String(rawBodyPart || '');

    const equipment = equipmentMap[rawEq.toLowerCase()] || rawEq;
    const targetMuscle = targetMap[rawTarget.toLowerCase()] || rawTarget;
    const bodyPartMuscle = muscleMap[rawBodyPart.toLowerCase()] || rawBodyPart;
    
    const primaryMuscles = [targetMuscle || bodyPartMuscle || 'chest'];
    const secondaryMuscles = [];

    const level = 'Intermediário';

    return {
      id: id,
      name: name,
      level: level,
      force: ex.force || 'push',
      equipment: equipment,
      category: 'Força',
      primaryMuscles: primaryMuscles,
      secondaryMuscles: secondaryMuscles,
      instructions: ex.instructions || [],
      images: [],
      gifUrl: ex.gifUrl || ''
    };
  });

  fs.writeFileSync('assets/premium_exercises.json', JSON.stringify(translated, null, 2), 'utf8');
  console.log(`Salvo em assets/premium_exercises.json! Total: ${translated.length} exercícios com GIFs.`);
}

start();
