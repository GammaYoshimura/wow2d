# Servidor del Vado

Con Go 1.27.4, ejecutar desde `server/`:

```sh
go run .
go test ./...
```

En Godot, iniciar el proyecto y pulsar **Entrar como invitado**. El cliente usa `ws://127.0.0.1:8080/game`. Para probar otra dirección, iniciar Godot con `-- --server=wss://juego.example.com/game` o con la variable `WOW2D_GAME_URL`. La compilación que se distribuya puede fijar el dominio real mediante `wow2d/network/game_url` en la sección `[wow2d]` de `project.godot` (clave `network/game_url`). El servidor escucha en la interfaz local de forma predeterminada. Se puede acceder desde otra máquina mediante un túnel SSH. `GET /healthz` devuelve 204 si el proceso está disponible.

El primer cliente recibe el centro de la primera casilla de aparición y el segundo el de la siguiente. La sesión invitada vive mientras se mantenga el socket. Antes de entrar se puede caminar en modo local. En una sesión en línea, el servidor simula a 20 ticks/s y envía la posición confirmada a 10 Hz. El cliente muestra la última posición recibida. Por ahora cada sesión recibe su propio personaje.

Para compilar el binario nativo en Ubuntu ARM64, ejecutar `go build -o bin/wow2d .` desde `server/`. Desde su mismo directorio de trabajo, arrancar con `./bin/wow2d`. Si se arranca en otra ruta, pasar el catálogo con `-map /ruta/content/plaza_v1.json`.

Con un servidor recién iniciado y desde la raíz del repositorio, ejecutar la prueba integrada de Godot. Usa dos escenas del juego, comprueba la colisión contra la valla y la parada al soltar la tecla, y verifica el mensaje que recibe un cliente con otra revisión del mapa.

```sh
WOW2D_GAME_URL=ws://127.0.0.1:8080/game godot --headless --path client --script res://tests/guest_connection_test.gd
```
