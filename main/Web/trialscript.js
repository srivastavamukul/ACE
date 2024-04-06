document.addEventListener("DOMContentLoaded", function() {
    setTimeout(function() {
      fadeDivIn();
    }, 2000); // Adjust the delay time as needed (in milliseconds)
  });
  
  function fadeDivIn() {
    const contentDiv = document.getElementById("content");
    contentDiv.style.display = "block";
    contentDiv.style.opacity = 0;
    
    const midpoint = window.innerHeight / 2;
    let currentOpacity = 0;
    
    const fadeInInterval = setInterval(function() {
      currentOpacity += 0.01;
      contentDiv.style.opacity = currentOpacity;
      
      if (currentOpacity >= 1) {
        clearInterval(fadeInInterval);
      }
    }, 10);
  }