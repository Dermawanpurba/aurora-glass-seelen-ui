const activePlayer = typeof players !== "undefined" && Array.isArray(players)
  ? players.find((p) => p.playing) || players[0]
  : null;

if (activePlayer && activePlayer.title) {
  const shortTitle = activePlayer.title.length > 20
    ? activePlayer.title.slice(0, 18) + "…"
    : activePlayer.title;
  return [icon("IoMusicalNotes"), " ", shortTitle];
}

return [icon("IoMusicalNotes"), " MP3"];
