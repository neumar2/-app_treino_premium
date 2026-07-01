const https = require('https');
const fs = require('fs');

const url = 'https://raw.githubusercontent.com/JahelCuadrado/ExerciseGymGifsDB/main/api/es/exercises.json';

const equipmentMap = {
  'barbell': 'Barra',
  'dumbbell': 'Halter',
  'cable': 'Polia/Cabo',
  'machine': 'Máquina',
  'smith': 'Máquina', // Smith can be grouped under Máquina
  'bodyweight': 'Peso do Corpo',
  'kettlebell': 'Kettlebell',
  'band': 'Elástico',
  'medicine-ball': 'Bola Medicinal',
  'stability-ball': 'Bola Suíça',
  'roller': 'Rolo de Espuma',
  'ez-bar': 'Barra W',
  'other': 'Outro',
  'none': 'Peso do Corpo'
};

const muscleMap = {
  'pectorals': 'chest',
  'lats': 'back',
  'upper-back': 'back',
  'lower-back': 'back',
  'traps': 'shoulders',
  'delts': 'shoulders',
  'biceps': 'biceps',
  'triceps': 'triceps',
  'forearms': 'forearms',
  'abs': 'abdominals',
  'quads': 'quadriceps',
  'hamstrings': 'hamstrings',
  'calves': 'calves',
  'glutes': 'glutes',
  'adductors': 'quadriceps',
  'abductors': 'quadriceps',
  'levator-scapulae': 'neck',
  'serratus-anterior': 'chest',
  'spine': 'back'
};

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
  console.log("Baixando base de dados secreta com GIFs reias (Espanhol)...");
  try {
    const rawData = await fetchJson(url);
    const rawArray = rawData.exercises;
    const translated = rawArray.map(ex => {
      const rawEq = (ex.equipment || 'bodyweight').toLowerCase();
      const equipment = equipmentMap[rawEq] || 'Outro';

      const primaryMuscle = ex.muscle ? (muscleMap[ex.muscle.toLowerCase()] || 'chest') : 'chest';
      const mappedPrimaryMuscles = [primaryMuscle];

      let level = 'Intermediário'; // DB doesn't have level, so default
      
      // Fix some spanish terms to PT-BR (optional quick fixes)
      let name = ex.name || '';
      name = name.replace(/mancuernas?/gi, 'halteres');
      name = name.replace(/espalda/gi, 'costas');
      name = name.replace(/flexión/gi, 'flexão');
      name = name.replace(/máquina/gi, 'máquina');
      name = name.replace(/sentadilla/gi, 'agachamento');
      name = name.replace(/peso corporal/gi, 'peso do corpo');

      const originalGifUrl = ex.gifUrl || '';
      const rawGifUrl = originalGifUrl.replace(
        'https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@main',
        'https://raw.githubusercontent.com/JahelCuadrado/ExerciseGymGifsDB/main'
      );

      return {
        id: ex.id,
        name: name,
        level: level,
        force: 'push', // default
        equipment: equipment,
        category: ex.category || 'Força',
        primaryMuscles: mappedPrimaryMuscles,
        secondaryMuscles: ex.secondaryMuscles || [],
        instructions: ex.instructions || [],
        images: [], // We have real GIFs now, no need for images fallback
        gifUrl: rawGifUrl
      };
    });

    fs.writeFileSync('assets/premium_exercises.json', JSON.stringify(translated, null, 2), 'utf8');
    console.log(`Sucesso! Foram salvos ${translated.length} exercícios em assets/premium_exercises.json`);
  } catch (error) {
    console.error("Erro ao processar:", error);
  }
}

run();
