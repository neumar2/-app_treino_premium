const Jimp = require('jimp');

async function removeBackground(input, output) {
  try {
    const image = await Jimp.read(input);
    
    // Replace near-white pixels with transparent
    image.scan(0, 0, image.bitmap.width, image.bitmap.height, function (x, y, idx) {
      const red = this.bitmap.data[idx + 0];
      const green = this.bitmap.data[idx + 1];
      const blue = this.bitmap.data[idx + 2];
      
      if (red > 200 && green > 200 && blue > 200) {
        this.bitmap.data[idx + 3] = 0; // alpha
      }
    });

    await image.writeAsync(output);
    console.log('Background removed for', output);
  } catch (err) {
    console.error(err);
  }
}

async function run() {
  await removeBackground('assets/female.jpeg', 'assets/female.png');
  await removeBackground('assets/male.jpeg', 'assets/male.png');
}

run();
