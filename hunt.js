const https = require('https');
const fs = require('fs');

async function searchAndDownload() {
  const query = encodeURIComponent('site:raw.githubusercontent.com "gifUrl" "bodyPart" "target"');
  const searchUrl = `https://html.duckduckgo.com/html/?q=${query}`;

  https.get(searchUrl, {
    headers: { 'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)' }
  }, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      // Regex to find github raw urls
      const regex = /https:\/\/raw\.githubusercontent\.com\/[^"'\s]+?\/(?:exercises?\.json|[a-zA-Z0-9_-]+\.json)/gi;
      const matches = [...new Set(data.match(regex) || [])];
      
      console.log("Found raw urls:", matches);

      if (matches.length > 0) {
        testUrl(matches[0], 0, matches);
      } else {
        console.log("No URLs found.");
      }
    });
  }).on('error', (e) => {
    console.error(e);
  });
}

function testUrl(url, index, matches) {
  console.log("Testing:", url);
  https.get(url, (res) => {
    if (res.statusCode === 200) {
       console.log("SUCCESS:", url);
       let data = '';
       res.on('data', chunk => data += chunk);
       res.on('end', () => {
         try {
           const json = JSON.parse(data);
           if (json.length > 0 && json[0].gifUrl) {
              console.log("VALID JSON with gifUrl found!");
              console.log("First item:", json[0].name, json[0].gifUrl);
           } else {
              console.log("Invalid format. Moving to next.");
              next(index, matches);
           }
         } catch(e) {
           console.log("Not JSON. Moving to next.");
           next(index, matches);
         }
       });
    } else {
       console.log("Failed with status:", res.statusCode);
       next(index, matches);
    }
  });
}

function next(index, matches) {
  if (index + 1 < matches.length) {
    testUrl(matches[index + 1], index + 1, matches);
  } else {
    console.log("All URLs failed.");
  }
}

searchAndDownload();
