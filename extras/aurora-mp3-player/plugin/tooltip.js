const activePlayer = typeof players !== "undefined" && Array.isArray(players)
  ? players.find((p) => p.playing) || players[0]
  : null;

if (activePlayer && activePlayer.title) {
  return `Sedang Diputar: ${activePlayer.title}${activePlayer.author ? " — " + activePlayer.author : ""}\nKlik untuk buka Paket Musik MP3 Aurora`;
}

return "Aurora MP3 Music Pack Player\nKlik untuk buka & putar Paket Musik (.mp3)";
