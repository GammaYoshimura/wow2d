# Servidor del Vado

Con Go 1.27.4, ejecutar desde `server/`:

```sh
go run .
go test ./...
```

En Godot, iniciar el proyecto y pulsar **Entrar como invitado**. El cliente usa `ws://127.0.0.1:8080/game`. Para probar otra dirección, iniciar Godot con la variable `WOW2D_GAME_URL` configurada. El servidor escucha en la interfaz local de forma predeterminada. Se puede acceder desde otra máquina mediante un túnel SSH. `GET /healthz` devuelve 204 si el proceso está disponible.

El primer cliente recibe el centro de la primera casilla de aparición y el segundo el de la siguiente. La sesión invitada vive mientras se mantenga el socket. En M00.03 el paseo se practica en modo local. Tras entrar, el personaje se sitúa en la posición confirmada por el servidor y espera la simulación de movimiento de M00.04.

Para compilar el binario nativo en Ubuntu ARM64, ejecutar `go build -o bin/wow2d .` desde `server/`. Desde su mismo directorio de trabajo, arrancar con `./bin/wow2d`. Si se arranca en otra ruta, pasar el catálogo con `-map /ruta/content/plaza_v1.json`.

Con un servidor recién iniciado y desde la raíz del repositorio, ejecutar la prueba integrada de Godot. Usa dos escenas del juego y comprueba también el mensaje que recibe un cliente con otra revisión del mapa.

```sh
WOW2D_GAME_URL=ws://127.0.0.1:8080/game godot --headless --path client --script res://tests/guest_connection_test.gd
```
