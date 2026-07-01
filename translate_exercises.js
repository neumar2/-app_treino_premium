const fs = require('fs');

const rawData = fs.readFileSync('assets/exercises.json', 'utf8');
const exercises = JSON.parse(rawData);

const equipmentMap = {
  'barbell': 'Barra',
  'dumbbell': 'Haltere',
  'cable': 'Cabo/Polia',
  'machine': 'Máquina',
  'body only': 'Peso Corporal',
  'kettlebell': 'Kettlebell',
  'bands': 'Elástico',
  'medicine ball': 'Bola Suíça',
  'exercise ball': 'Bola de Exercício',
  'foam roll': 'Rolo de Espuma',
  'e-z curl bar': 'Barra W',
  'other': 'Outro'
};

const levelMap = {
  'beginner': 'Iniciante',
  'intermediate': 'Intermediário',
  'expert': 'Avançado'
};

const forceMap = {
  'pull': 'Puxar',
  'push': 'Empurrar',
  'static': 'Isométrico'
};

const categoryMap = {
  'strength': 'Força',
  'stretching': 'Alongamento',
  'plyometrics': 'Pliometria',
  'strongman': 'Strongman',
  'powerlifting': 'Powerlifting',
  'cardio': 'Cardio',
  'olympic weightlifting': 'LPO'
};

const nameDictionary = {
  'Barbell': 'com Barra',
  'Dumbbell': 'com Halteres',
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
  'Triceps': 'Tríceps',
  'Biceps': 'Bíceps',
  'Shoulder': 'Ombro',
  'Press': 'Desenvolvimento',
  'Reverse': 'Invertido'
};

function translateName(name) {
  let newName = name;
  for (const [eng, pt] of Object.entries(nameDictionary)) {
    const regex = new RegExp(`\\b${eng}\\b`, 'gi');
    newName = newName.replace(regex, pt);
  }
  return newName;
}

const translated = exercises.map(ex => {
  const generatedId = ex.id || ex.name.toLowerCase().replace(/[^a-z0-9]+/g, '_');
  return {
    ...ex,
    id: generatedId,
    name: translateName(ex.name),
    level: levelMap[ex.level] || ex.level,
    force: forceMap[ex.force] || ex.force,
    equipment: equipmentMap[ex.equipment] || ex.equipment,
    category: categoryMap[ex.category] || ex.category,
    images: (ex.images || []).map(imgPath => `https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/${imgPath}`),
    gifUrl: (ex.images && ex.images.length > 0) ? `https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/${ex.images[0]}` : ''
  };
});

fs.writeFileSync('assets/premium_exercises.json', JSON.stringify(translated, null, 2), 'utf8');
console.log(`Traduzidos ${translated.length} exercícios.`);
