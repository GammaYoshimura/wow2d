# Movimiento de la plaza

Las posiciones están en píxeles de mundo. X aumenta hacia la derecha e Y hacia abajo. Una casilla mide 32 píxeles y el centro de una casilla es su esquina superior izquierda más (16, 16).

El explorador ocupa un círculo de radio 10 px centrado en sus pies y camina a 144 px/s. Se limita la longitud del vector de entrada a 1 antes de aplicar la velocidad. Los sólidos del catálogo son rectángulos completos de una casilla. Los bordes del mapa también frenan el círculo. La cámara sigue al explorador dentro del rectángulo de la zona.
