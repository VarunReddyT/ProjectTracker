let isSelectionActive = false;
let activeSockets = new Set();

module.exports = {
  activateSelection: () => {
    isSelectionActive = true;
    console.log('Project selection mode ACTIVATED');
  },

  deactivateSelection: () => {
    isSelectionActive = false;
    activeSockets.forEach(socket => socket.disconnect());
    activeSockets.clear();
    console.log('Project selection mode DEACTIVATED');
  },

  socketGuard: (socket, next) => {
    if (isSelectionActive) {
      activeSockets.add(socket);
      next();
    } else {
      socket.emit('session_inactive', { 
        message: 'Project selection is not currently active' 
      });
      socket.disconnect();
    }
  }
};