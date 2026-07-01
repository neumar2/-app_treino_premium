const https = require('https');
const fs = require('fs');

const url = 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json';
const baseUrlImages = 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/';

const equipmentMap = {
  'barbell': 'Barra',
  'dumbbell': 'Halter',
  'cable': 'Polia/Cabo',
  'machine': 'Máquina',
  'body only': 'Peso do Corpo',
  'body_only': 'Peso do Corpo',
  'bodyweight': 'Peso do Corpo',
  'kettlebell': 'Kettlebell',
  'bands': 'Elástico',
  'medicine ball': 'Bola Medicinal',
  'exercise ball': 'Bola Suíça',
  'foam roll': 'Rolo de Espuma',
  'e-z curl bar': 'Barra W',
  'smith machine': 'Máquina Smith',
  'other': 'Outro',
  'none': 'Peso do Corpo'
};

const muscleMap = {
  'chest': 'chest',
  'middle back': 'back',
  'lower back': 'back',
  'lats': 'back',
  'shoulders': 'shoulders',
  'biceps': 'biceps',
  'triceps': 'triceps',
  'forearms': 'forearms',
  'abdominals': 'abdominals',
  'quadriceps': 'quadriceps',
  'hamstrings': 'hamstrings',
  'calves': 'calves',
  'glutes': 'glutes',
  'neck': 'neck',
  'traps': 'shoulders',
  'abductors': 'quadriceps',
  'adductors': 'quadriceps'
};

const levelMap = {
  'beginner': 'Iniciante',
  'intermediate': 'Intermediário',
  'expert': 'Avançado',
  'advanced': 'Avançado'
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
  let newName = name.replace(/\b([a-z])/g, char => char.toUpperCase());
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

async function run() {
  console.log("Baixando base de dados gratuita com imagens...");
  try {
    const rawData = await fetchJson(url);
    const translated = rawData.map(ex => {
      const name = translateName(ex.name || '');
      
      const rawEq = (ex.equipment || 'body only').toLowerCase();
      const equipment = equipmentMap[rawEq] || 'Outro';

      let mappedPrimaryMuscles = [];
      if (ex.primaryMuscles) {
         mappedPrimaryMuscles = ex.primaryMuscles.map(m => muscleMap[m.toLowerCase()] || 'chest');
      } else {
         mappedPrimaryMuscles = ['chest'];
      }

      const level = levelMap[(ex.level || 'intermediate').toLowerCase()] || 'Intermediário';
      
      let imageUrl = '';
      if (ex.images && ex.images.length > 0) {
         imageUrl = baseUrlImages + ex.images[0];
      }

      return {
        id: ex.id,
        name: name,
        level: level,
        force: ex.force || 'push',
        equipment: equipment,
        category: ex.category || 'Força',
        primaryMuscles: mappedPrimaryMuscles,
        secondaryMuscles: ex.secondaryMuscles || [],
        instructions: ex.instructions || [],
        images: ex.images ? ex.images.map(img => baseUrlImages + img) : [],
        gifUrl: imageUrl // Usando a imagem estática para substituir o gif, já que gifs pesam muito
      };
    });

    fs.writeFileSync('assets/premium_exercises.json', JSON.stringify(translated, null, 2), 'utf8');
    console.log(`Sucesso! Foram salvos ${translated.length} exercícios em assets/premium_exercises.json`);
  } catch (error) {
    console.error("Erro ao processar:", error);
  }
}

run();
