# MMORPG 2D en Godot · Roadmap de desarrollo

**Primera meta jugable.** En Vado del Fresno, un jugador encuentra a Iria junto al pozo, acepta el encargo de tres lobos, sale por el sendero, vuelve con un colmillo y alcanza el nivel 2. Al día siguiente reaparece con su mochila, su experiencia y el encargo entregado. Un segundo jugador puede acompañarlo y ver los mismos lobos caer.

**Juego propuesto.** MMORPG de fantasía en vista cenital para PC, con sesiones cortas de exploración en solitario y expediciones cooperativas más largas. El vado conecta un bosque y una cantera. Sus materiales alimentan los oficios del pueblo, sus encargos enseñan las habilidades de clase y sus caminos llevan a las primeras mazmorras. Grupos, comercio, hermandades, PvP voluntario, bandas y temporadas amplían ese mismo mundo persistente. Los nombres y cifras de diseño son valores iniciales para probar.

**Cómo usar este documento.** Cada micromilestone tiene una issue, un efecto observable en Godot, una responsabilidad del servidor y una prueba que decide su cierre. El orden de lectura es el orden recomendado de juego. Las dependencias indican qué tiene que funcionar para empezar una entrega. Las issues recogen el estado y la evidencia de cada implementación. [Ir al ai_handoff](#ai_handoff) · [Ver las issues](https://github.com/GammaYoshimura/wow2d/issues)

## Ruta de entregas

Se conservan los números de fase del documento de partida. M05 precede a M04 para probar la cooperación antes de ampliar el mercado. M08 precede a M07 para aprovechar la progresión cooperativa ya construida. La marcha del juego se evalúa en cuatro cortes.

| Corte | Qué probar con jugadores |
| --- | --- |
| Primer prototipo compartido · M00 | Abrir dos clientes, reconocerse junto al pozo y rodear la misma valla con latencia. |
| Primer corte vertical · M01 | Entregar los cinco encargos, alcanzar nivel 2 y recuperar el personaje tras reiniciar el servidor. Aquí se decide si caminar, combatir y cobrar la primera recompensa invitan a repetir. |
| Alfa cooperativa · M02, M03, M05 | Comparar tres clases, recorrer tres zonas y terminar tres mazmorras en grupos de 3–5. Registrar dónde se pierden, cuándo entienden el peligro y qué decisiones cambian el combate. |
| Mundo operable · M04, M06, M08, M07, M09 | Seguir una pieza de mineral desde la veta hasta otro jugador, organizar una banda de diez, completar una partida PvP voluntaria y mantener el mundo durante dos semanas de ensayo. M10 aborda ampliaciones de capacidad según las mediciones. |

| Fase | Micromilestones | Seguimiento |
| --- | ---: | --- |
| [M00 · Primer paseo compartido](#fase-00) | 7 | [Milestone en GitHub](https://github.com/GammaYoshimura/wow2d/milestone/1) |
| [M01 · Un encargo en Vado del Fresno](#fase-01) | 15 | [Milestone en GitHub](https://github.com/GammaYoshimura/wow2d/milestone/2) |
| [M02 · Combate y progresión de clase](#fase-02) | 13 | [Milestone en GitHub](https://github.com/GammaYoshimura/wow2d/milestone/3) |
| [M03 · Un mundo de tres zonas](#fase-03) | 13 | [Milestone en GitHub](https://github.com/GammaYoshimura/wow2d/milestone/4) |
| [M05 · Grupos y mazmorras](#fase-05) | 14 | [Milestone en GitHub](https://github.com/GammaYoshimura/wow2d/milestone/5) |
| [M04 · Oficios y economía](#fase-04) | 11 | [Milestone en GitHub](https://github.com/GammaYoshimura/wow2d/milestone/6) |
| [M06 · Amistades y hermandades](#fase-06) | 10 | [Milestone en GitHub](https://github.com/GammaYoshimura/wow2d/milestone/7) |
| [M08 · Banda y objetivos de temporada](#fase-08) | 10 | [Milestone en GitHub](https://github.com/GammaYoshimura/wow2d/milestone/8) |
| [M07 · PvP voluntario](#fase-07) | 8 | [Milestone en GitHub](https://github.com/GammaYoshimura/wow2d/milestone/9) |
| [M09 · Operación y lanzamiento](#fase-09) | 11 | [Milestone en GitHub](https://github.com/GammaYoshimura/wow2d/milestone/10) |
| [M10 · Más jugadores y más reinos](#fase-10) | 15 | [Milestone en GitHub](https://github.com/GammaYoshimura/wow2d/milestone/11) |

## Reglas del juego y reparto de responsabilidades

| Decisión | Cliente Godot 4.x con GDScript | Servidor autoritativo en Ubuntu Server 26.04 LTS |
| --- | --- | --- |
| Caminar por el mundo | Teclado en ocho direcciones, cámara cenital, selección por clic o tecla y una acción para interactuar. La predicción da respuesta inmediata al personaje propio. | La zona simula a paso fijo. Valida dirección, velocidad, colisión y transición. Un solo propietario escribe el estado de cada actor en cada momento. |
| Lanzar una habilidad | Barra de acciones, objetivo visible, anticipación del golpe y explicación de los rechazos. Interpolar a los demás actores. | Resolver en orden de tick alcance, recursos, efectos, daño, curación y muerte. Cada muerte tiene un ID que comparten crédito, botín y telemetría. |
| Completar un objetivo | NPCs y diario muestran oferta, progreso, entrega y recompensa. La bolsa distingue capacidad disponible y objeto pendiente. | Las misiones consumen eventos confirmados. Objetivo, elegibilidad y recompensa se deciden en servidor. Inventario, XP y saldo se confirman antes de mostrarlos como definitivos. |
| Jugar acompañado | Mostrar cercanía, grupo, rol, zona e instancia. Los avisos de jefe usan forma y tiempo además de color. | Una zona coordina los encuentros locales. Sesiones, pertenencia al grupo, custodia de objetos y derechos semanales sobreviven a los cambios de zona según sus reglas. |
| Crear contenido | Componer suelo, obstáculos y decoración con `TileMapLayer`. Usar escenas para actores, HUD y señales de encuentro, con arte provisional hasta probar el combate. | Consumir el mismo catálogo versionado de mapas, formas de colisión, NPCs, habilidades, diálogos, misiones, objetos, recetas y encuentros. Validar IDs, referencias, coordenadas, pesos y prerrequisitos al cargarlo. |

**Base técnica elegida para arrancar.** Cliente Godot 4.x de escritorio y servidor Go en Ubuntu Server 26.04 LTS. Un proceso modular de Go contiene entrada de sesiones, bucle de zona y lógica de personajes, misiones y objetos. PostgreSQL conserva el progreso duradero. Las sesiones de invitado y el mundo de prueba viven en memoria en M00. M01 incorpora las cuentas persistentes. Se puede introducir Redis cuando las medidas justifiquen compartir presencia o colas entre procesos.

**Contrato de red.** HTTPS para cuenta y selección de personaje, WebSocket seguro para la sesión de juego, con mensajes de aplicación versionados que Godot lee mediante `WebSocketPeer`. Al entrar se negocian versión de protocolo, revisión de contenido y zona. Una entrada de movimiento lleva secuencia y dirección. La instantánea devuelve tick, posición y última secuencia aplicada. Una operación duradera como `turn_in_quest` lleva un ID de solicitud y devuelve resultado y revisión de estado. Los reintentos recuperan el resultado ya confirmado. Tras reconectar se envía una instantánea completa y se descartan entradas de la sesión anterior. Medir las colas de transporte en el ensayo con latencia de M00.06. [WebSocket en Godot](https://docs.godotengine.org/en/stable/tutorials/networking/websocket.html)

**Mapa y contenido compartidos.** Usar IDs estables como `zone.vado`, `npc.iria` y `quest.tres_lobos`. El catálogo es la fuente de geometría y reglas de juego. El cliente convierte casillas y origen a coordenadas de escena y el servidor usa la misma convención para movimiento y alcance. Una misión referencia NPC de oferta y entrega, eventos de objetivo, cantidad, prerrequisitos y recompensa. Una prueba de contenido carga el catálogo completo y detecta referencias rotas antes de jugar. [TileMapLayer en Godot](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html)

**Persistencia.** Separar el estado efímero del encuentro de los datos de cuenta, personaje, inventario, misión y economía. Guardar posición en puntos seguros y al salir. Confirmar compras, recompensas y cambios de titular en una transacción con restricciones de unicidad y revisión. Para un traspaso de zona, retener origen o punto de retorno hasta que destino confirme el relevo. Para objetos en comercio, correo o mercado debe poder reconstruirse quién tenía su custodia en cada paso.

**Entorno mínimo.** La versión inicial del cliente es Godot 4.7.2 estable. El servidor usa Go 1.27.4 y protocolo de juego v2 desde M00.04. Registrar la versión de PostgreSQL cuando se incorpore. Reservar `client/` para Godot, `server/` para Go y migraciones y `content/` para datos compartidos. Crear cada ruta cuando llegue su primera entrega. Probar el primer paseo y las demos de fase contra el binario de servidor en Ubuntu 26.04. [Distribución oficial de Ubuntu Server 26.04 LTS](https://releases.ubuntu.com/26.04/)

## Qué medir al jugar

Son objetivos iniciales de diseño. Registrar compilación, máquina, mapa, jugadores, duración y latencia de cada medición para decidir con qué cifras continuar.

| Momento | Observación y referencia inicial |
| --- | --- |
| Movimiento compartido | Empezar a 20 ticks/s de simulación y 10 instantáneas/s. El presupuesto por tick es 50 ms. En el ensayo de diez clientes de M01, buscar p95 de simulación ≤ 35 ms y documentar máximos y correcciones. |
| Primera sesión | Probar con una persona que desconozca el mapa. Objetivo de 10–15 minutos desde crear personaje hasta la primera entrega de caza. Registrar dónde pidió ayuda y por qué. |
| Combate | Para un lobo del mismo nivel, empezar con 6–12 s de combate. Comparar tiempo para vencer, vida final y habilidades usadas con equipo básico y mejorado. |
| Mundo y expedición | Objetivo inicial de transición entre zonas inferior a 2 s en p95 en la máquina de referencia. Para una primera mazmorra normal, buscar 15–25 min y registrar derrotas por mecánica y tiempo de reagrupación. |
| Integridad | En cada ensayo con dos clientes que reclaman el mismo bien o recompensa, cotejar objetos, movimientos de moneda y recibos antes y después. Una diferencia inexplicada mantiene abierta la entrega. |
| Operación | Medir sesiones, abandono de misión, retención por cohorte, errores, tiempo de tick, creación y consumo de oro. En una restauración, expresar tanto el progreso que podría perderse como el tiempo hasta volver a jugar. |

<a id="fase-00"></a>

## M00 · Primer paseo compartido

Hacer que dos exploradores se encuentren junto al pozo y que una pared tenga el mismo borde para ambos.

**Demo de salida.** Una persona abre dos clientes, rodea el pozo y ve al otro explorador detenerse ante la misma valla. El servidor de Ubuntu conserva la autoridad sobre ambas posiciones.

### [M00.01 · La plaza y el pozo](https://github.com/GammaYoshimura/wow2d/issues/1)

Punto de partida.

- **Godot.** Dibujar en TileMapLayer una plaza cenital de 32 × 32 casillas, con pozo, camino y dos accesos distinguibles.
- **Servidor.** Definir el mapa plaza_v1 en datos con tamaño de casilla, origen, celdas sólidas y puntos de aparición.
- **Aceptación.** Abrir la escena en Godot y comprobar sobre la cuadrícula que pozo y accesos coinciden con los datos.

### [M00.02 · Caminar hasta la valla](https://github.com/GammaYoshimura/wow2d/issues/2)

Requiere [M00.01](https://github.com/GammaYoshimura/wow2d/issues/1).

- **Godot.** Mover un CharacterBody2D en ocho direcciones, con cámara limitada al mapa y animación de reposo.
- **Servidor.** Fijar en el contrato unidades por segundo, huella del actor y regla para normalizar diagonales.
- **Aceptación.** Recorrer el camino en horizontal y diagonal durante el mismo tiempo. La distancia difiere menos de un 2 % y la cámara se detiene en el borde.

### [M00.03 · Entrar como explorador invitado](https://github.com/GammaYoshimura/wow2d/issues/3)

Requiere [M00.01](https://github.com/GammaYoshimura/wow2d/issues/1).

- **Godot.** Añadir Entrar y mostrar el punto de aparición recibido mediante WebSocketPeer.
- **Servidor.** Abrir una sesión de invitado en memoria y responder con identificador de entidad, zona, revisión del mapa y tick.
- **Aceptación.** Dos entradas obtienen entidades distintas. Un cliente con revisión incompatible recibe un mensaje legible.

### [M00.04 · El servidor decide el paso](https://github.com/GammaYoshimura/wow2d/issues/4)

Requiere [M00.02](https://github.com/GammaYoshimura/wow2d/issues/2), [M00.03](https://github.com/GammaYoshimura/wow2d/issues/3).

- **Godot.** Enviar dirección y secuencia de entrada, aplicar la posición confirmada y detener al soltar la tecla.
- **Servidor.** Simular a paso fijo, limitar velocidad por tick y resolver las paredes contra el mapa compartido.
- **Aceptación.** Mantener el movimiento contra la valla y soltarlo. Cliente y servidor terminan en la misma cara y el actor queda quieto.

### [M00.05 · Encontrarse junto al pozo](https://github.com/GammaYoshimura/wow2d/issues/5)

Requiere [M00.04](https://github.com/GammaYoshimura/wow2d/issues/4).

- **Godot.** Crear y retirar avatares remotos por ID e interpolar entre dos posiciones confirmadas.
- **Servidor.** Emitir aparición, instantáneas y salida a las conexiones de la plaza.
- **Aceptación.** A ve a B rodear el pozo. Al salir B desaparece una vez y A sigue jugando.

### [M00.06 · Caminar con latencia](https://github.com/GammaYoshimura/wow2d/issues/6)

Requiere [M00.05](https://github.com/GammaYoshimura/wow2d/issues/5).

- **Godot.** Predecir el movimiento propio y reconciliar las entradas pendientes al llegar la confirmación.
- **Servidor.** Devolver la última secuencia aplicada y registrar el error de corrección en unidades de mapa.
- **Aceptación.** Con 120 ms de ida y vuelta simulados, soltar el mando ante la valla deja ambas posiciones a menos de una casilla en un segundo.

### [M00.07 · Primer paseo desde Ubuntu](https://github.com/GammaYoshimura/wow2d/issues/7)

Requiere [M00.06](https://github.com/GammaYoshimura/wow2d/issues/6).

- **Godot.** Mostrar estado de conexión y ofrecer volver a la plaza tras interrumpirse la sesión invitada.
- **Servidor.** Ejecutar el servidor en Ubuntu Server 26.04 LTS, vaciar entidades de sesiones caducadas y registrar tiempos de tick.
- **Aceptación.** Dos clientes recorren el circuito cinco minutos contra Ubuntu. Interrumpir uno, volver a entrar y comprobar que hay exactamente dos entidades al final.

<a id="fase-01"></a>

## M01 · Un encargo en Vado del Fresno

Validar en una sola aldea el recorrido de crear personaje, ayudar a la guardabosques y volver con una recompensa.

**Demo de salida.** Una cuenta nueva completa cinco encargos enlazados, llega al nivel 2, conversa con otro jugador y conserva bolsa y progreso tras salir y volver.

### [M01.01 · Una cuenta que vuelve](https://github.com/GammaYoshimura/wow2d/issues/8)

Requiere [M00.07](https://github.com/GammaYoshimura/wow2d/issues/7).

- **Godot.** Añadir registro, acceso, salida y un mensaje de sesión caducada.
- **Servidor.** Guardar cuentas en PostgreSQL, proteger contraseñas con hash adecuado para contraseñas y emitir sesiones revocables.
- **Aceptación.** Crear una cuenta de prueba, salir y volver. La sesión anterior deja de abrir la plaza.

### [M01.02 · Elegir personaje](https://github.com/GammaYoshimura/wow2d/issues/9)

Requiere [M01.01](https://github.com/GammaYoshimura/wow2d/issues/8).

- **Godot.** Crear, nombrar y elegir un personaje desde una lista con retrato provisional.
- **Servidor.** Vincular personaje y propietario, reservar nombre normalizado y asignar el punto inicial.
- **Aceptación.** Dos cuentas intentan el mismo nombre. Solo una lo obtiene y cada lista contiene sus propios personajes.

### [M01.03 · Volver al sendero](https://github.com/GammaYoshimura/wow2d/issues/10)

Requiere [M01.02](https://github.com/GammaYoshimura/wow2d/issues/9).

- **Godot.** Mostrar el personaje en el último punto seguro confirmado y distinguir reconexión de primera entrada.
- **Servidor.** Guardar zona y posición válida con revisión de sesión. Impedir dos escritores simultáneos para el personaje.
- **Aceptación.** Salir junto a la valla, reiniciar el proceso y volver. Dos accesos simultáneos dejan un único avatar activo.

### [M01.04 · Hablar con Iria](https://github.com/GammaYoshimura/wow2d/issues/11)

Requiere [M01.03](https://github.com/GammaYoshimura/wow2d/issues/10).

- **Godot.** Resaltar a la guardabosques al acercarse y cerrar el diálogo al alejarse.
- **Servidor.** Cargar NPC, radio de interacción y líneas por ID desde el catálogo. Validar posición al hablar.
- **Aceptación.** Desde el pozo no se abre la charla. Al lado de Iria aparece su saludo.

### [M01.05 · Aceptar el encargo de los lobos](https://github.com/GammaYoshimura/wow2d/issues/12)

Requiere [M01.04](https://github.com/GammaYoshimura/wow2d/issues/11).

- **Godot.** Mostrar título, objetivo y recompensa prevista. Fijar el encargo aceptado en el diario.
- **Servidor.** Crear para cada personaje el estado ofrecida → activa. Guardar el objetivo de tres lobos desde datos.
- **Aceptación.** Aceptar dos veces, reconectar y verificar una entrada activa con contador 0/3.

### [M01.06 · El lobo sale al camino](https://github.com/GammaYoshimura/wow2d/issues/13)

Requiere [M01.03](https://github.com/GammaYoshimura/wow2d/issues/10).

- **Godot.** Animar reposo, patrulla y regreso a la guarida con un indicador de objetivo.
- **Servidor.** Crear un punto de aparición y una ruta corta con búsqueda de camino sobre celdas transitables.
- **Aceptación.** Observar dos vueltas completas. El lobo bordea el pozo y los dos clientes coinciden en su destino.

### [M01.07 · Primer intercambio de golpes](https://github.com/GammaYoshimura/wow2d/issues/14)

Requiere [M01.06](https://github.com/GammaYoshimura/wow2d/issues/13).

- **Godot.** Seleccionar objetivo, atacar y leer salud, alcance y respuesta al impacto.
- **Servidor.** Resolver golpe básico y contraataque con alcance, cadencia, vida y evento de muerte.
- **Aceptación.** Fuera de alcance la salud permanece igual. Dentro del alcance ambos clientes ven la misma vida y una única muerte.

### [M01.08 · Crédito por la caza](https://github.com/GammaYoshimura/wow2d/issues/15)

Requiere [M01.05](https://github.com/GammaYoshimura/wow2d/issues/12), [M01.07](https://github.com/GammaYoshimura/wow2d/issues/14).

- **Godot.** Actualizar el rastreador por muerte confirmada y señalar cuándo regresar a Iria.
- **Servidor.** Otorgar crédito al vencedor elegible, recordar el ID de muerte y programar la reaparición del lobo.
- **Aceptación.** Dos jugadores miran la misma caza. Solo el vencedor avanza y el cuarto lobo deja el contador en 3/3.

### [M01.09 · Un colmillo en la mochila](https://github.com/GammaYoshimura/wow2d/issues/16)

Requiere [M01.07](https://github.com/GammaYoshimura/wow2d/issues/14).

- **Godot.** Abrir el botín, recoger el colmillo y mostrarlo en una bolsa de ocho huecos.
- **Servidor.** Generar botín personal desde una tabla y transferirlo atómicamente al inventario comprobando capacidad.
- **Aceptación.** Dos pulsaciones sobre Recoger añaden un solo colmillo. Con la bolsa llena, el objeto sigue disponible.

### [M01.10 · Entregar y cobrar](https://github.com/GammaYoshimura/wow2d/issues/17)

Requiere [M01.08](https://github.com/GammaYoshimura/wow2d/issues/15), [M01.09](https://github.com/GammaYoshimura/wow2d/issues/16).

- **Godot.** Habilitar Entregar junto a Iria, mostrar la recompensa y archivar la misión.
- **Servidor.** Confirmar objetivos y otorgar experiencia y monedas en la misma transacción que la entrega.
- **Aceptación.** Con 2/3 Iria recuerda lo que falta. Con 3/3 entrega una recompensa aunque se repita la solicitud.

### [M01.11 · Llegar al nivel dos](https://github.com/GammaYoshimura/wow2d/issues/18)

Requiere [M01.10](https://github.com/GammaYoshimura/wow2d/issues/17).

- **Godot.** Mostrar barra de experiencia, cambio de nivel y puntos de vida máximos.
- **Servidor.** Leer umbrales de nivel desde datos y recalcular atributos al cruzar el umbral.
- **Aceptación.** Un personaje situado a 1 XP del umbral entrega el encargo, sube a nivel 2 y conserva el excedente tras reconectar.

### [M01.12 · Caer y volver al refugio](https://github.com/GammaYoshimura/wow2d/issues/19)

Requiere [M01.07](https://github.com/GammaYoshimura/wow2d/issues/14).

- **Godot.** Mostrar derrota, deshabilitar el ataque y ofrecer reaparecer en el pozo.
- **Servidor.** Invalidar acciones de un personaje caído y devolverlo al refugio una vez por muerte.
- **Aceptación.** Caer ante un lobo, pulsar dos veces el botón y volver con una vida completa y la misma bolsa.

### [M01.13 · Cinco encargos en el vado](https://github.com/GammaYoshimura/wow2d/issues/20)

Requiere [M01.10](https://github.com/GammaYoshimura/wow2d/issues/17), [M01.11](https://github.com/GammaYoshimura/wow2d/issues/18).

- **Godot.** Guiar al jugador de Iria al vigía y al curtidor con indicadores de diálogo y diario.
- **Servidor.** Añadir en datos bienvenida, caza, recogida de colmillo, entrega al curtidor y regreso al vigía con sus prerrequisitos.
- **Aceptación.** Con cuenta nueva se completan los cinco en orden y se alcanza nivel 2. Tras recargar, todos conservan su estado.

### [M01.14 · Dos canales de conversación](https://github.com/GammaYoshimura/wow2d/issues/21)

Requiere [M01.03](https://github.com/GammaYoshimura/wow2d/issues/10).

- **Godot.** Distinguir Local y Global mediante nombre y color, y mantener el foco de escritura separado del movimiento.
- **Servidor.** Enrutar global a conectados y local por radio. Limitar frecuencia y longitud de publicación.
- **Aceptación.** Dos jugadores cercanos oyen ambos canales. Al alejar a uno, solo recibe el global.

### [M01.15 · Una sesión completa bajo observación](https://github.com/GammaYoshimura/wow2d/issues/22)

Requiere [M01.12](https://github.com/GammaYoshimura/wow2d/issues/19), [M01.13](https://github.com/GammaYoshimura/wow2d/issues/20), [M01.14](https://github.com/GammaYoshimura/wow2d/issues/21).

- **Godot.** Recorrer el itinerario de la aldea y mostrar un motivo recuperable si cae la conexión.
- **Servidor.** Medir sesiones, errores, pasos del encargo, muertes y duración de tick con IDs de prueba seudónimos.
- **Aceptación.** Con diez clientes durante 15 minutos, uno completa los cinco encargos, cae, vuelve y reconecta con la bolsa intacta. Adjuntar tiempos y conteos.

<a id="fase-02"></a>

## M02 · Combate y progresión de clase

Dar a cada rol una decisión distinta ante la misma amenaza y hacer perceptible la mejora del equipo.

**Demo de salida.** Guardián, Arcanista y Custodia superan al Colmillo Viejo. La repetición con una pieza mejor permite explicar con el registro de combate qué cambió.

### [M02.01 · Tres oficios de combate](https://github.com/GammaYoshimura/wow2d/issues/23)

Requiere [M01.15](https://github.com/GammaYoshimura/wow2d/issues/22).

- **Godot.** Ampliar la selección con Guardián, Arcanista y Custodia, su recurso y su habilidad inicial.
- **Servidor.** Guardar clase y atributos base. Migrar los personajes del slice con una elección de clase única.
- **Aceptación.** Un personaje antiguo conserva nivel y objetos al elegir. Tres personajes nuevos tienen fichas distintas.

### [M02.02 · Una barra que marca el ritmo](https://github.com/GammaYoshimura/wow2d/issues/24)

Requiere [M02.01](https://github.com/GammaYoshimura/wow2d/issues/23).

- **Godot.** Asignar dos teclas de habilidad y mostrar coste, espera y motivo de rechazo en la barra.
- **Servidor.** Resolver coste y reutilización con reloj de simulación y datos por habilidad.
- **Aceptación.** Pulsar dos veces en un tick consume un solo coste. Al terminar la espera vuelve a habilitarse el botón.

### [M02.03 · El Guardián protege](https://github.com/GammaYoshimura/wow2d/issues/25)

Requiere [M02.02](https://github.com/GammaYoshimura/wow2d/issues/24).

- **Godot.** Añadir Golpe de escudo y Guardia con indicador de objetivo y duración.
- **Servidor.** Generar furia al recibir golpes y aplicar reducción temporal mientras Guardia esté activa.
- **Aceptación.** Frente al mismo lobo, Guardia reduce el daño del siguiente golpe y el registro muestra cuánto absorbió.

### [M02.04 · El Arcanista decide cuándo parar](https://github.com/GammaYoshimura/wow2d/issues/26)

Requiere [M02.02](https://github.com/GammaYoshimura/wow2d/issues/24).

- **Godot.** Canalizar Brasa con barra de lanzamiento y cancelar al caminar.
- **Servidor.** Validar maná y resolver lanzamiento, interrupción y tiempo de recuperación en ticks.
- **Aceptación.** Caminar a media barra cancela Brasa. Completarla inmóvil causa exactamente un impacto y un coste.

### [M02.05 · La Custodia elige a quién curar](https://github.com/GammaYoshimura/wow2d/issues/27)

Requiere [M02.02](https://github.com/GammaYoshimura/wow2d/issues/24).

- **Godot.** Seleccionar un aliado herido, lanzar Alivio y mostrar la curación efectiva.
- **Servidor.** Validar relación amistosa, distancia y vida máxima. Separar curación efectiva de exceso.
- **Aceptación.** Curar a un aliado al 90 % llena solo la vida que falta. Fuera de alcance conserva el maná.

### [M02.06 · Amenaza y cambio de objetivo](https://github.com/GammaYoshimura/wow2d/issues/28)

Requiere [M02.03](https://github.com/GammaYoshimura/wow2d/issues/25), [M02.05](https://github.com/GammaYoshimura/wow2d/issues/27).

- **Godot.** Señalar a quién persigue el enemigo y mostrar el efecto de Provocar.
- **Servidor.** Mantener amenaza por criatura, sumar daño y curación y dar prioridad temporal a la provocación.
- **Aceptación.** El sanador atrae al lobo, el guardián lo recupera y el objetivo se limpia al volver a la guarida.

### [M02.07 · Veneno, escudo y control](https://github.com/GammaYoshimura/wow2d/issues/29)

Requiere [M02.02](https://github.com/GammaYoshimura/wow2d/issues/24).

- **Godot.** Mostrar iconos con temporizador para veneno, escudo, ralentización y aturdimiento.
- **Servidor.** Definir duración, pulsos, absorción y política de acumulación en datos de efectos.
- **Aceptación.** Dos venenos del mismo origen siguen la regla declarada. Al caducar el control, el actor recupera el movimiento.

### [M02.08 · Vestir un arma y una coraza](https://github.com/GammaYoshimura/wow2d/issues/30)

Requiere [M02.01](https://github.com/GammaYoshimura/wow2d/issues/23).

- **Godot.** Comparar, equipar y quitar objetos en mano y torso, mostrando el cambio de atributos.
- **Servidor.** Mantener la propiedad de instancia, validar clase y ranura y recalcular fuerza, agilidad, intelecto y vitalidad.
- **Aceptación.** Cambiar de arma actualiza daño, quitarla restaura el valor y reconectar conserva el conjunto.

### [M02.09 · Un botín que merece inspección](https://github.com/GammaYoshimura/wow2d/issues/31)

Requiere [M01.09](https://github.com/GammaYoshimura/wow2d/issues/16), [M02.08](https://github.com/GammaYoshimura/wow2d/issues/30).

- **Godot.** Distinguir común y raro con texto y aspecto, y previsualizar sus atributos.
- **Servidor.** Versionar tablas ponderadas, usar tiradas del servidor y exponer una semilla reproducible en pruebas.
- **Aceptación.** Una tabla de prueba de peso único entrega siempre el objeto esperado. La tabla de juego genera ambas rarezas en la muestra acordada.

### [M02.10 · Elegir un talento](https://github.com/GammaYoshimura/wow2d/issues/32)

Requiere [M02.02](https://github.com/GammaYoshimura/wow2d/issues/24), [M02.08](https://github.com/GammaYoshimura/wow2d/issues/30).

- **Godot.** Presentar dos pasivas excluyentes al nivel 3 y explicar el cambio al seleccionarlas.
- **Servidor.** Aplicar curva de XP hasta nivel 5, requisitos y gasto de un punto persistente.
- **Aceptación.** Al alcanzar nivel 3 se desbloquea una elección. Repetirla consume un solo punto y la pasiva reaparece al entrar.

### [M02.11 · Esquivar al élite](https://github.com/GammaYoshimura/wow2d/issues/33)

Requiere [M02.04](https://github.com/GammaYoshimura/wow2d/issues/26), [M02.07](https://github.com/GammaYoshimura/wow2d/issues/29).

- **Godot.** Dibujar el cono de carga con borde y animación anticipatoria sobre el suelo.
- **Servidor.** Fijar origen, dirección y tick de impacto de Colmillo Rojo antes de resolver la zona dañina.
- **Aceptación.** Con un actor dentro del cono y otro fuera al impacto, solo pierde vida el primero.

### [M02.12 · El Colmillo Viejo cambia de fase](https://github.com/GammaYoshimura/wow2d/issues/34)

Requiere [M02.06](https://github.com/GammaYoshimura/wow2d/issues/28), [M02.11](https://github.com/GammaYoshimura/wow2d/issues/33).

- **Godot.** Señalar el aullido a media vida y marcar el lobo que responde.
- **Servidor.** Crear un minijefe con fase al 50 %, un refuerzo por transición y reinicio al abandonar el combate.
- **Aceptación.** Cruzar el umbral dos veces tras curarlo genera una oleada en el intento. Abandonar y volver restaura la fase inicial.

### [M02.13 · Comparar tres maneras de ganar](https://github.com/GammaYoshimura/wow2d/issues/35)

Requiere [M02.09](https://github.com/GammaYoshimura/wow2d/issues/31), [M02.10](https://github.com/GammaYoshimura/wow2d/issues/32), [M02.12](https://github.com/GammaYoshimura/wow2d/issues/34).

- **Godot.** Mostrar daño, mitigación y curación efectiva en un resumen comprensible.
- **Servidor.** Registrar por clase, nivel y equipo la duración de encuentros, derrotas y recursos finales.
- **Aceptación.** Repetir el minijefe con las tres clases y dos conjuntos de equipo. Publicar las mediciones y justificar un ajuste o la decisión de mantener valores.

<a id="fase-03"></a>

## M03 · Un mundo de tres zonas

Conectar Vado del Fresno, Bosque de Bruma y Cantera Roja mediante caminos por los que apetezca volver.

**Demo de salida.** Un personaje recorre las tres zonas, escolta un convoy, desbloquea un viaje y regresa otro día para un encuentro repetible.

### [M03.01 · Un puente hacia el Bosque de Bruma](https://github.com/GammaYoshimura/wow2d/issues/36)

Requiere [M02.13](https://github.com/GammaYoshimura/wow2d/issues/35).

- **Godot.** Anticipar la carga de la escena vecina al aproximarse al puente y conservar la cámara durante el cruce.
- **Servidor.** Preparar en destino una transferencia con ID único, confirmar el cambio de propietario y recuperar la última posición segura si se interrumpe.
- **Aceptación.** Cortar la conexión al cruzar en cada sentido. Al volver, el personaje existe en una sola zona y puede seguir caminando.

### [M03.02 · Ver solo a quienes están cerca](https://github.com/GammaYoshimura/wow2d/issues/37)

Requiere [M03.01](https://github.com/GammaYoshimura/wow2d/issues/36).

- **Godot.** Incorporar o retirar entidades al entrar y salir de la vecindad, sin repetir animaciones de aparición.
- **Servidor.** Suscribir por celdas cercanas con un margen de salida y emitir altas y bajas por ID.
- **Aceptación.** Dos jugadores cruzan el límite de visión tres veces. Cada cliente acaba con el conjunto esperado y bajan los bytes frente al envío a toda la zona.

### [M03.03 · Un mapa que se descubre andando](https://github.com/GammaYoshimura/wow2d/issues/38)

Requiere [M03.01](https://github.com/GammaYoshimura/wow2d/issues/36).

- **Godot.** Abrir un mapa con senderos y revelar un mojón al visitarlo.
- **Servidor.** Persistir los puntos de interés descubiertos por personaje y versión de zona.
- **Aceptación.** Visitar el aserradero descubre su icono. Un personaje nuevo conserva el mapa por explorar.

### [M03.04 · Hierbas para la boticaria](https://github.com/GammaYoshimura/wow2d/issues/39)

Requiere [M03.03](https://github.com/GammaYoshimura/wow2d/issues/38).

- **Godot.** Resaltar hierbas frescas y mostrar el recuento de recolección en el diario.
- **Servidor.** Reservar el nodo al recoger, programar su reaparición y acreditar el material y el objetivo juntos.
- **Aceptación.** Dos actores usan la última hierba. Solo uno la recoge y el otro puede usarla cuando reaparece.

### [M03.05 · La ruta de la Cantera Roja](https://github.com/GammaYoshimura/wow2d/issues/40)

Requiere [M03.01](https://github.com/GammaYoshimura/wow2d/issues/36), [M03.03](https://github.com/GammaYoshimura/wow2d/issues/38).

- **Godot.** Crear la tercera zona con cantera, bifurcación, boticaria y ruta visible de regreso.
- **Servidor.** Definir portales de ida y vuelta, obstáculos, encuentros y punto de retorno en datos.
- **Aceptación.** Un personaje viaja Vado → Bosque → Cantera → Vado, con las tres zonas registradas y tiempos de transición medidos.

### [M03.06 · El convoy de piedra](https://github.com/GammaYoshimura/wow2d/issues/41)

Requiere [M03.05](https://github.com/GammaYoshimura/wow2d/issues/40).

- **Godot.** Señalar al carretero, su integridad y el próximo punto de parada.
- **Servidor.** Simular ruta, pausa por emboscada, condición de fracaso y reinicio de escolta.
- **Aceptación.** Completar la ruta da crédito al acompañante. Si cae el carro, el encargo se puede repetir desde la salida.

### [M03.07 · Un encargo con dos objetivos](https://github.com/GammaYoshimura/wow2d/issues/42)

Requiere [M03.04](https://github.com/GammaYoshimura/wow2d/issues/39), [M03.06](https://github.com/GammaYoshimura/wow2d/issues/41).

- **Godot.** Mostrar por separado hierbas reunidas y convoy protegido, con diálogo final contextual.
- **Servidor.** Componer objetivos y prerrequisitos en el catálogo reutilizando eventos de recolección y escolta.
- **Aceptación.** Cumplir los objetivos en ambos órdenes con dos personajes abre la misma entrega una sola vez.

### [M03.08 · Reputación con los canteros](https://github.com/GammaYoshimura/wow2d/issues/43)

Requiere [M03.07](https://github.com/GammaYoshimura/wow2d/issues/42).

- **Godot.** Mostrar rango, ganancia y respuesta distinta del capataz al ganar confianza.
- **Servidor.** Registrar cambios de reputación con su origen y umbral de acceso por facción.
- **Aceptación.** Al cruzar el primer umbral se abre un diálogo. Repetir la entrega anterior conserva la reputación.

### [M03.09 · Hitos de viaje](https://github.com/GammaYoshimura/wow2d/issues/44)

Requiere [M03.05](https://github.com/GammaYoshimura/wow2d/issues/40).

- **Godot.** Elegir entre dos mojones descubiertos y mostrar el destino antes de partir.
- **Servidor.** Validar descubrimiento, estado fuera de combate y punto de llegada usando la transferencia existente.
- **Aceptación.** Un mojón desconocido figura bloqueado. Tras visitarlo, el viaje deja un solo avatar en destino.

### [M03.10 · La primera montura](https://github.com/GammaYoshimura/wow2d/issues/45)

Requiere [M03.08](https://github.com/GammaYoshimura/wow2d/issues/43), [M03.09](https://github.com/GammaYoshimura/wow2d/issues/44).

- **Godot.** Invocar la mula de cantera y comunicar dónde se puede montar.
- **Servidor.** Desbloquearla por reputación, aplicar velocidad de viaje y desmontar al entrar en combate.
- **Aceptación.** Medir el mismo tramo a pie y montado. Entrar en combate restaura la velocidad a pie en ambos clientes.

### [M03.11 · El vigía de la niebla](https://github.com/GammaYoshimura/wow2d/issues/46)

Requiere [M03.02](https://github.com/GammaYoshimura/wow2d/issues/37), [M03.05](https://github.com/GammaYoshimura/wow2d/issues/40).

- **Godot.** Mostrar indicios del élite raro y señal del encuentro público que convoca al derrotarlo.
- **Servidor.** Gestionar ventanas de aparición, jefe de zona inicial y crédito por participación elegible.
- **Aceptación.** Dos jugadores participan y reciben crédito propio. Quien llega después de la muerte ve el tiempo de retorno.

### [M03.12 · Un motivo para volver mañana](https://github.com/GammaYoshimura/wow2d/issues/47)

Requiere [M03.07](https://github.com/GammaYoshimura/wow2d/issues/42), [M03.08](https://github.com/GammaYoshimura/wow2d/issues/43), [M03.11](https://github.com/GammaYoshimura/wow2d/issues/46).

- **Godot.** Ofrecer una misión diaria que alterne bosque y cantera e indicar su próxima renovación.
- **Servidor.** Elegir variante por fecha UTC y limitar la recompensa a una por personaje y periodo.
- **Aceptación.** Con un reloj de prueba, entregar antes y después del cambio de día concede dos recompensas en total.

### [M03.13 · Luz y lluvia del bosque (opcional)](https://github.com/GammaYoshimura/wow2d/issues/48)

Requiere [M03.05](https://github.com/GammaYoshimura/wow2d/issues/40).

- **Godot.** Aplicar transiciones de día, noche y lluvia manteniendo legibles caminos y señales.
- **Servidor.** Publicar semilla ambiental y época de zona para que dos clientes coincidan al entrar.
- **Aceptación.** Entrar a mitad de una tormenta desde dos clientes produce la misma fase y todas las señales de combate siguen visibles.

<a id="fase-05"></a>

## M05 · Grupos y mazmorras

Pasar de ayudar a otro jugador en el camino a coordinarse para vencer a un jefe.

**Demo de salida.** Un grupo de 3–5 completa tres mazmorras normales. Una segunda compañía puede recorrerlas al mismo tiempo. Hay acceso manual, buscador y progresión de dificultad.

### [M05.01 · Formar una compañía](https://github.com/GammaYoshimura/wow2d/issues/49)

Requiere [M03.12](https://github.com/GammaYoshimura/wow2d/issues/47).

- **Godot.** Invitar por retrato y aceptar, rechazar o solicitar unirse desde la ficha.
- **Servidor.** Crear grupo de hasta cinco, validar invitaciones y expirar las pendientes.
- **Aceptación.** Dos personas forman un grupo. Una invitación expirada informa del motivo y una sexta plaza queda bloqueada.

### [M05.02 · Liderazgo y reencuentro](https://github.com/GammaYoshimura/wow2d/issues/50)

Requiere [M05.01](https://github.com/GammaYoshimura/wow2d/issues/49).

- **Godot.** Mostrar líder, integrantes y desconexión temporal. Añadir salir y ceder liderazgo.
- **Servidor.** Guardar la pertenencia mientras dure la sesión del grupo y reasignar líder al agotarse su gracia.
- **Aceptación.** El líder cede el mando y se reconecta al otro lado del puente. Todos ven la misma lista.

### [M05.03 · Leer al grupo en combate](https://github.com/GammaYoshimura/wow2d/issues/51)

Requiere [M05.01](https://github.com/GammaYoshimura/wow2d/issues/49), [M02.05](https://github.com/GammaYoshimura/wow2d/issues/27).

- **Godot.** Mostrar barras de salud y rol y permitir seleccionar para curar desde el panel.
- **Servidor.** Distribuir salud y rol declarado entre compañeros, respetando zona y alcance al curar.
- **Aceptación.** Elegir a un aliado herido desde el panel lo cura. Un compañero en otra zona aparece fuera de alcance.

### [M05.04 · La puerta de la Mina Hueca](https://github.com/GammaYoshimura/wow2d/issues/52)

Requiere [M05.02](https://github.com/GammaYoshimura/wow2d/issues/50).

- **Godot.** Entrar por el portal y reconocer en pantalla la compañía y la salida.
- **Servidor.** Asignar una instancia de Mina Hueca por grupo y validar la pertenencia al entrar o volver.
- **Aceptación.** Dos grupos entran a la vez. Sus puertas y criaturas evolucionan por separado.

### [M05.05 · La primera sala se abre](https://github.com/GammaYoshimura/wow2d/issues/53)

Requiere [M05.04](https://github.com/GammaYoshimura/wow2d/issues/52).

- **Godot.** Presentar dos centinelas y hacer visible el sello que cae tras vencerlos.
- **Servidor.** Persistir el estado de la sala durante el intento y abrir el paso tras ambas muertes.
- **Aceptación.** Vencer a uno deja la puerta cerrada. Vencer al segundo la abre para todos, incluido quien se reconecta.

### [M05.06 · La guardiana de las vetas](https://github.com/GammaYoshimura/wow2d/issues/54)

Requiere [M05.03](https://github.com/GammaYoshimura/wow2d/issues/51), [M05.05](https://github.com/GammaYoshimura/wow2d/issues/53).

- **Godot.** Anticipar desprendimientos y marcar dos refugios para repartir al grupo.
- **Servidor.** Resolver golpes de área y una fase de fractura que exige ocupar dos refugios distintos.
- **Aceptación.** Concentrar al grupo en un punto falla la mecánica. Dividirlo permite derrotar a la guardiana.

### [M05.07 · Volver tras una derrota](https://github.com/GammaYoshimura/wow2d/issues/55)

Requiere [M05.06](https://github.com/GammaYoshimura/wow2d/issues/54).

- **Godot.** Mostrar punto de reagrupación, estado del jefe y opción de reentrada.
- **Servidor.** Reiniciar el encuentro al caer todos y conservar las salas ya despejadas mientras viva la instancia.
- **Aceptación.** Tras una derrota completa, el jefe recupera toda la vida, la puerta sigue abierta y el grupo puede terminar la mina.

### [M05.08 · Botín personal de mazmorra](https://github.com/GammaYoshimura/wow2d/issues/56)

Requiere [M05.07](https://github.com/GammaYoshimura/wow2d/issues/55).

- **Godot.** Abrir el cofre con el resultado individual y el historial del reparto.
- **Servidor.** Registrar elegibilidad, tabla y tirada por participante e ID de encuentro.
- **Aceptación.** Tres participantes abren el cofre, uno reconecta y repite. Siguen existiendo tres resoluciones auditables.

### [M05.09 · Buscar por rol](https://github.com/GammaYoshimura/wow2d/issues/57)

Requiere [M05.03](https://github.com/GammaYoshimura/wow2d/issues/51), [M05.04](https://github.com/GammaYoshimura/wow2d/issues/52).

- **Godot.** Elegir tanque, daño o sanación, aceptar una propuesta y conservar la entrada manual.
- **Servidor.** Formar grupos de 3–5 con tanque, sanador y al menos un daño. Reservar plazas durante la aceptación.
- **Aceptación.** Tres roles compatibles reciben propuesta. Si uno declina, los restantes vuelven a cola y un grupo manual sigue entrando.

### [M05.10 · El Archivo de Sal](https://github.com/GammaYoshimura/wow2d/issues/58)

Requiere [M05.07](https://github.com/GammaYoshimura/wow2d/issues/55).

- **Godot.** Construir una sala de lectura y un jefe con dos runas distinguibles por forma.
- **Servidor.** Parametrizar en datos el orden de runas y la ventana de interrupción usando el sistema de encuentros.
- **Aceptación.** Una secuencia incorrecta reinicia las runas. La correcta interrumpe al jefe y permite terminar la segunda mazmorra.

### [M05.11 · El Taller Sumergido](https://github.com/GammaYoshimura/wow2d/issues/59)

Requiere [M05.07](https://github.com/GammaYoshimura/wow2d/issues/55).

- **Godot.** Dibujar las dos válvulas, el nivel de agua y la alarma del guardián.
- **Servidor.** Elevar el agua por pulsos y aceptar válvulas simultáneas de dos personajes distintos.
- **Aceptación.** Dos jugadores coordinan las válvulas y un tercero contiene al jefe. La tercera mazmorra concede su cofre.

### [M05.12 · De normal a heroico](https://github.com/GammaYoshimura/wow2d/issues/60)

Requiere [M05.08](https://github.com/GammaYoshimura/wow2d/issues/56), [M05.10](https://github.com/GammaYoshimura/wow2d/issues/58), [M05.11](https://github.com/GammaYoshimura/wow2d/issues/59).

- **Godot.** Seleccionar dificultad y previsualizar la mecánica y el requisito de acceso.
- **Servidor.** Conservar la dificultad por intento. Desbloquear heroico al completar normal y añadir un modificador de encuentro.
- **Aceptación.** El mismo jefe tiene una zona de peligro adicional en heroico. El registro distingue ambas victorias.

### [M05.13 · Una semana mítica](https://github.com/GammaYoshimura/wow2d/issues/61)

Requiere [M05.12](https://github.com/GammaYoshimura/wow2d/issues/60).

- **Godot.** Mostrar dificultad mítica, mutador semanal y estado de recompensa por jefe.
- **Servidor.** Fijar mutador y derecho a botín por personaje, jefe y semana UTC. Permitir ayudar tras cobrar.
- **Aceptación.** Ganar dos veces en la misma semana concede un premio mítico. Avanzar el reloj a la siguiente habilita otro.

### [M05.14 · Expedición con tres y con cinco](https://github.com/GammaYoshimura/wow2d/issues/62)

Requiere [M05.09](https://github.com/GammaYoshimura/wow2d/issues/57), [M05.13](https://github.com/GammaYoshimura/wow2d/issues/61).

- **Godot.** Guiar desde el buscador hasta el cofre final y ofrecer regresar a la entrada.
- **Servidor.** Medir éxito por composición, tiempos de sala y abandonos, separando grupos manuales y emparejados.
- **Aceptación.** Completar las tres normales con tres jugadores y repetir una con cinco. Verificar aislamiento entre grupos y revisar los tiempos registrados.

<a id="fase-04"></a>

## M04 · Oficios y economía

Seguir el viaje de un mineral desde la veta hasta las manos de otro jugador.

**Demo de salida.** Dos cuentas extraen mineral, forjan una pieza, negocian y venden en el mercado. Las existencias, saldos y comisiones cuadran incluso después de una desconexión.

### [M04.01 · La bolsa y el monedero](https://github.com/GammaYoshimura/wow2d/issues/63)

Requiere [M01.15](https://github.com/GammaYoshimura/wow2d/issues/22).

- **Godot.** Separar pilas, reunir materiales y ver el saldo antes y después de cobrar una misión.
- **Servidor.** Añadir movimientos de moneda con origen y destino y conservar la cantidad total al dividir o reunir pilas.
- **Aceptación.** Separar 7 unidades en 3 y 4, reunirlas y reconectar. El total sigue en 7 y el saldo cuadra con los movimientos.

### [M04.02 · Mineral de la cantera](https://github.com/GammaYoshimura/wow2d/issues/64)

Requiere [M03.04](https://github.com/GammaYoshimura/wow2d/issues/39), [M04.01](https://github.com/GammaYoshimura/wow2d/issues/63).

- **Godot.** Empuñar una herramienta y ver el avance de extracción y las cargas de la veta.
- **Servidor.** Validar herramienta, distancia, reserva temporal y capacidad antes de descontar una carga.
- **Aceptación.** Dos mineros compiten por la última carga. Se entrega un mineral y se consume una carga.

### [M04.03 · Aprender herrería](https://github.com/GammaYoshimura/wow2d/issues/65)

Requiere [M04.02](https://github.com/GammaYoshimura/wow2d/issues/64).

- **Godot.** Aprender el oficio y consultar el recetario con materiales disponibles y requisito de maestría.
- **Servidor.** Guardar nivel de oficio y recetas conocidas. Otorgar la primera receta en la conversación con el maestro.
- **Aceptación.** Antes de aprenderla la receta figura cerrada. Tras la charla aparece disponible incluso al volver a entrar.

### [M04.04 · Forjar un cuchillo](https://github.com/GammaYoshimura/wow2d/issues/66)

Requiere [M04.03](https://github.com/GammaYoshimura/wow2d/issues/65).

- **Godot.** Elegir la receta, ver el coste de dos minerales y recoger el cuchillo terminado.
- **Servidor.** Validar estación, consumir ingredientes, crear pieza y acreditar oficio en una transacción.
- **Aceptación.** Con dos minerales se obtiene un cuchillo. Reintentar la fabricación con el mismo ID devuelve el resultado inicial.

### [M04.05 · Una pieza vinculada](https://github.com/GammaYoshimura/wow2d/issues/67)

Requiere [M04.04](https://github.com/GammaYoshimura/wow2d/issues/66), [M02.08](https://github.com/GammaYoshimura/wow2d/issues/30).

- **Godot.** Mostrar antes de recoger o equipar cuándo una pieza quedará vinculada.
- **Servidor.** Aplicar vínculo al recoger o al equipar según plantilla y consultar el mismo atributo en transferencias.
- **Aceptación.** Un cuchillo comerciable pasa a vinculado al equiparse. Una pieza vinculada al recoger ya nace con dueño fijo.

### [M04.06 · Intercambiar cara a cara](https://github.com/GammaYoshimura/wow2d/issues/68)

Requiere [M04.05](https://github.com/GammaYoshimura/wow2d/issues/67).

- **Godot.** Mostrar ambas ofertas y solicitar confirmación nueva cuando cambie una de ellas.
- **Servidor.** Reservar bienes y saldo, versionar ofertas y transferir todo al recibir dos confirmaciones compatibles.
- **Aceptación.** Cambiar una moneda invalida ambas confirmaciones. Una desconexión antes del acuerdo devuelve las reservas.

### [M04.07 · Un paquete para otro jugador](https://github.com/GammaYoshimura/wow2d/issues/69)

Requiere [M04.06](https://github.com/GammaYoshimura/wow2d/issues/68).

- **Godot.** Redactar correo, adjuntar un objeto y reclamarlo desde el buzón aunque el remitente haya salido.
- **Servidor.** Mantener el objeto en custodia hasta su entrega o devolución por caducidad.
- **Aceptación.** Con bolsa llena se conserva el adjunto. Hacer sitio y reclamar dos veces entrega una sola pieza.

### [M04.08 · Poner un lote a la venta](https://github.com/GammaYoshimura/wow2d/issues/70)

Requiere [M04.07](https://github.com/GammaYoshimura/wow2d/issues/69).

- **Godot.** Publicar cantidad, precio y duración y consultar ofertas por categoría y nombre.
- **Servidor.** Reservar el lote, registrar la comisión aplicable e indexar anuncios por categoría y precio.
- **Aceptación.** Un lote publicado desaparece de la bolsa, aparece en la búsqueda y al caducar vuelve por correo.

### [M04.09 · Dos compradores, una venta](https://github.com/GammaYoshimura/wow2d/issues/71)

Requiere [M04.08](https://github.com/GammaYoshimura/wow2d/issues/70).

- **Godot.** Confirmar el precio final y mostrar vendido si otra persona llega antes.
- **Servidor.** Cerrar el anuncio una vez, mover el oro y enviar mercancía e ingreso descontada la comisión.
- **Aceptación.** Dos cuentas compran el mismo lote simultáneamente. Hay un cargo, un ingreso neto, una comisión y una entrega.

### [M04.10 · Mejorar o reciclar](https://github.com/GammaYoshimura/wow2d/issues/72)

Requiere [M04.04](https://github.com/GammaYoshimura/wow2d/issues/66), [M04.05](https://github.com/GammaYoshimura/wow2d/issues/67).

- **Godot.** Previsualizar coste y resultado de reforzar una pieza o convertirla en material.
- **Servidor.** Validar titular y versión, cobrar oro por refuerzo o consumir la pieza al reciclarla.
- **Aceptación.** Un cuchillo reforzado gana el atributo previsto. Reciclarlo elimina la instancia y entrega el material una vez.

### [M04.11 · Cuadrar el mercado del vado](https://github.com/GammaYoshimura/wow2d/issues/73)

Requiere [M04.09](https://github.com/GammaYoshimura/wow2d/issues/71), [M04.10](https://github.com/GammaYoshimura/wow2d/issues/72).

- **Godot.** Exponer comisiones, costes de mejora y espera de vetas antes de confirmar.
- **Servidor.** Medir por día emisión, sumideros, volumen y concentración de extracción. Parametrizar reposición y rendimiento decreciente del nodo.
- **Aceptación.** Simular un día con diez cuentas. El cambio total de oro equivale a emisión menos sumideros y se identifica qué veta concentró la extracción.

<a id="fase-06"></a>

## M06 · Amistades y hermandades

Dar al grupo motivos para volver a jugar junto y un objetivo común que sobreviva a una sesión.

**Demo de salida.** Una hermandad prepara una expedición usando calendario, banco y contribuciones. Un miembro desconectado recibe el aviso y otro puede bloquear a un remitente.

### [M06.01 · Encontrar a un amigo](https://github.com/GammaYoshimura/wow2d/issues/74)

Requiere [M05.02](https://github.com/GammaYoshimura/wow2d/issues/50).

- **Godot.** Abrir el perfil de un compañero, solicitar amistad y ver si está conectado.
- **Servidor.** Guardar amistad mutua, consentimiento y visibilidad del perfil con presencia entre zonas.
- **Aceptación.** Aceptar la solicitud muestra presencia en ambos lados. Una cuenta ajena solo ve los campos públicos.

### [M06.02 · Silenciar a un jugador](https://github.com/GammaYoshimura/wow2d/issues/75)

Requiere [M06.01](https://github.com/GammaYoshimura/wow2d/issues/74), [M01.14](https://github.com/GammaYoshimura/wow2d/issues/21).

- **Godot.** Bloquear desde el chat, revisar la lista y poder desbloquear desde ajustes.
- **Servidor.** Filtrar susurros e invitaciones según bloqueos y conservar la lista entre sesiones.
- **Aceptación.** Un remitente bloqueado deja de aparecer en el chat y sus invitaciones se descartan incluso tras reconectar.

### [M06.03 · Un mensaje para mañana](https://github.com/GammaYoshimura/wow2d/issues/76)

Requiere [M06.02](https://github.com/GammaYoshimura/wow2d/issues/75), [M04.07](https://github.com/GammaYoshimura/wow2d/issues/69).

- **Godot.** Enviar un mensaje de texto fuera de línea y marcarlo como leído al abrirlo.
- **Servidor.** Entregar al buzón social con ID estable y verificar bloqueo también al recuperar mensajes.
- **Aceptación.** B vuelve, lee el mensaje una vez y lo conserva leído en el segundo acceso.

### [M06.04 · Fundar la hermandad](https://github.com/GammaYoshimura/wow2d/issues/77)

Requiere [M06.01](https://github.com/GammaYoshimura/wow2d/issues/74).

- **Godot.** Nombrar la hermandad, elegir un emblema y aceptar invitaciones específicas.
- **Servidor.** Crear hermandad y membresía única, reservar nombre y asignar fundador.
- **Aceptación.** Dos fundadores solicitan el mismo nombre. Una hermandad lo registra y un invitado pasa a su lista.

### [M06.05 · Rangos que se entienden](https://github.com/GammaYoshimura/wow2d/issues/78)

Requiere [M06.04](https://github.com/GammaYoshimura/wow2d/issues/77).

- **Godot.** Mostrar permisos de miembro, oficial y líder con controles para ascender y transferir liderazgo.
- **Servidor.** Comprobar el rango en cada acción y asegurar que siempre exista un líder mientras haya miembros.
- **Aceptación.** Un miembro recibe rechazo al invitar sin permiso. Tras ascenderlo puede invitar y la transferencia deja un único líder.

### [M06.06 · Un canal para la hermandad](https://github.com/GammaYoshimura/wow2d/issues/79)

Requiere [M06.02](https://github.com/GammaYoshimura/wow2d/issues/75), [M06.05](https://github.com/GammaYoshimura/wow2d/issues/78).

- **Godot.** Añadir canal de hermandad y noticias de incorporaciones y ascensos.
- **Servidor.** Distribuir mensajes por membresía entre zonas y registrar noticias con paginación.
- **Aceptación.** Dos miembros en zonas distintas conversan. Quien abandona deja de recibir el canal y las noticias nuevas.

### [M06.07 · El banco común](https://github.com/GammaYoshimura/wow2d/issues/80)

Requiere [M06.05](https://github.com/GammaYoshimura/wow2d/issues/78), [M04.06](https://github.com/GammaYoshimura/wow2d/issues/68).

- **Godot.** Depositar o retirar desde una pestaña y consultar autor, fecha y cantidad.
- **Servidor.** Usar custodia de la hermandad, permisos de retirada y registro transaccional.
- **Aceptación.** Dos oficiales intentan retirar la última pieza. Hay una retirada y el historial permite localizar la pieza.

### [M06.08 · La despensa de la expedición](https://github.com/GammaYoshimura/wow2d/issues/81)

Requiere [M06.07](https://github.com/GammaYoshimura/wow2d/issues/80).

- **Godot.** Aportar material a un objetivo de prestigio y mostrar el beneficio cosmético al completarlo.
- **Servidor.** Consumir aportaciones y otorgar un desbloqueo colectivo al alcanzar el umbral.
- **Aceptación.** Dos aportes completan la despensa. Ambos quedan atribuidos y el emblema se desbloquea una vez.

### [M06.09 · Una cita con la hermandad](https://github.com/GammaYoshimura/wow2d/issues/82)

Requiere [M06.03](https://github.com/GammaYoshimura/wow2d/issues/76), [M06.06](https://github.com/GammaYoshimura/wow2d/issues/79), [M06.08](https://github.com/GammaYoshimura/wow2d/issues/81).

- **Godot.** Programar una expedición, verla en hora local y apuntarse desde otra zona.
- **Servidor.** Guardar horario UTC, capacidad y confirmaciones. Enviar aviso a miembros con entrega fuera de línea.
- **Aceptación.** Un oficial programa la salida. Un miembro reconecta en otra zona, recibe el aviso y ocupa una sola plaza.

### [M06.10 · Reportar desde el chat](https://github.com/GammaYoshimura/wow2d/issues/83)

Requiere [M06.02](https://github.com/GammaYoshimura/wow2d/issues/75), [M06.06](https://github.com/GammaYoshimura/wow2d/issues/79).

- **Godot.** Elegir un mensaje, indicar motivo y recibir número de caso.
- **Servidor.** Capturar contexto mínimo del mensaje, restringir acceso a moderación y registrar el tratamiento del caso.
- **Aceptación.** Un moderador de prueba localiza el caso y anota una resolución. Un jugador corriente solo puede consultar su acuse.

<a id="fase-08"></a>

## M08 · Banda y objetivos de temporada

Ofrecer a diez personajes preparados una expedición semanal con responsabilidades individuales.

**Demo de salida.** Diez jugadores completan los dos jefes de Observatorio Hundido. El registro semanal, las apariencias y la meta de temporada sobreviven al reinicio.

### [M08.01 · Convertir un grupo en banda](https://github.com/GammaYoshimura/wow2d/issues/84)

Requiere [M05.14](https://github.com/GammaYoshimura/wow2d/issues/62), [M06.09](https://github.com/GammaYoshimura/wow2d/issues/82).

- **Godot.** Dividir diez plazas en dos subgrupos, marcar tanques y lanzar una comprobación de listos.
- **Servidor.** Ampliar el modelo de grupo con límite de banda, líder y respuesta individual.
- **Aceptación.** Diez jugadores ocupan dos subgrupos. La comprobación enumera al ausente y admite su respuesta tardía.

### [M08.02 · Reunir diez en el observatorio](https://github.com/GammaYoshimura/wow2d/issues/85)

Requiere [M08.01](https://github.com/GammaYoshimura/wow2d/issues/84), [M05.09](https://github.com/GammaYoshimura/wow2d/issues/57).

- **Godot.** Ofrecer buscador de banda con rol y entrada directa para una banda ya reunida.
- **Servidor.** Ensamblar dos tanques, dos sanadores y seis personajes de daño. Reservar instancia y reponer una baja antes de entrar.
- **Aceptación.** Tanto la cola completa como una banda manual acceden al mismo tipo de instancia con diez plazas distintas.

### [M08.03 · El Cartógrafo Ciego](https://github.com/GammaYoshimura/wow2d/issues/86)

Requiere [M08.02](https://github.com/GammaYoshimura/wow2d/issues/85).

- **Godot.** Mostrar dos lentes en extremos opuestos y proyectar el recorrido de un haz.
- **Servidor.** Asignar dos portadores, validar la alineación simultánea y restablecer lentes tras cada intento.
- **Aceptación.** Dos portadores distintos rompen el escudo. Si uno cae, el encuentro puede reiniciarse y completarse.

### [M08.04 · La Astrónoma de Marea](https://github.com/GammaYoshimura/wow2d/issues/87)

Requiere [M08.03](https://github.com/GammaYoshimura/wow2d/issues/86).

- **Godot.** Señalar las mareas por forma y sonido y marcar a los jugadores llamados a separarse.
- **Servidor.** Alternar marcas, oleadas y fase final, fijando participantes en cada resolución.
- **Aceptación.** La banda supera dos cambios de fase, rescata a un compañero marcado y derrota al jefe final.

### [M08.05 · Progreso de banda semanal](https://github.com/GammaYoshimura/wow2d/issues/88)

Requiere [M08.04](https://github.com/GammaYoshimura/wow2d/issues/87), [M05.13](https://github.com/GammaYoshimura/wow2d/issues/61).

- **Godot.** Mostrar jefes derrotados, botín elegible y fecha de renovación antes de entrar.
- **Servidor.** Guardar por semana tanto el punto de avance de la banda como el derecho individual de cobro.
- **Aceptación.** Cambiar de banda permite ayudar, conserva el historial personal y evita cobrar dos veces al Cartógrafo.

### [M08.06 · Conjunto de astrónomo](https://github.com/GammaYoshimura/wow2d/issues/89)

Requiere [M08.05](https://github.com/GammaYoshimura/wow2d/issues/88), [M02.08](https://github.com/GammaYoshimura/wow2d/issues/30).

- **Godot.** Comparar dos piezas de tier y previsualizar la bonificación al vestir ambas.
- **Servidor.** Asignar botín elegible por rol y activar o retirar la bonificación según piezas realmente equipadas.
- **Aceptación.** Equipar la segunda pieza modifica una habilidad medible. Quitársela restaura el valor anterior.

### [M08.07 · Un desafío para veteranos](https://github.com/GammaYoshimura/wow2d/issues/90)

Requiere [M08.04](https://github.com/GammaYoshimura/wow2d/issues/87), [M08.06](https://github.com/GammaYoshimura/wow2d/issues/89).

- **Godot.** Seleccionar la variante veterana y anticipar el segundo haz del Cartógrafo.
- **Servidor.** Asociar una variante de patrón y una tabla de recompensa a esa dificultad.
- **Aceptación.** Repetir el primer jefe en ambas dificultades muestra el haz extra y registra dos resultados distinguibles.

### [M08.08 · Vestir una apariencia ganada](https://github.com/GammaYoshimura/wow2d/issues/91)

Requiere [M08.06](https://github.com/GammaYoshimura/wow2d/issues/89).

- **Godot.** Mostrar colección, vista previa y aplicación de apariencia sobre equipo compatible.
- **Servidor.** Desbloquear apariencias por personaje y guardar el aspecto separado de los atributos efectivos.
- **Aceptación.** Cambiar el aspecto se ve desde otro cliente y una prueba de daño produce el mismo resultado que antes.

### [M08.09 · Un logro de reputación semanal](https://github.com/GammaYoshimura/wow2d/issues/92)

Requiere [M08.05](https://github.com/GammaYoshimura/wow2d/issues/88), [M03.08](https://github.com/GammaYoshimura/wow2d/issues/43).

- **Godot.** Mostrar el logro por rescatar a los dos portadores, la reputación del Observatorio y una meta semanal.
- **Servidor.** Escuchar eventos de rescate, acreditar el logro y otorgar reputación una vez por periodo.
- **Aceptación.** Repetir el rescate conserva el primer logro y un solo incremento semanal de reputación.

### [M08.10 · Cerrar la temporada](https://github.com/GammaYoshimura/wow2d/issues/93)

Requiere [M08.07](https://github.com/GammaYoshimura/wow2d/issues/90), [M08.08](https://github.com/GammaYoshimura/wow2d/issues/91), [M08.09](https://github.com/GammaYoshimura/wow2d/issues/92).

- **Godot.** Mostrar metas activas, cuenta atrás, recompensa cosmética y archivo de la temporada anterior.
- **Servidor.** Versionar las metas y liquidar recompensas ganadas al cerrar la temporada con un reloj de prueba.
- **Aceptación.** Cambiar de temporada conserva apariencias y logros históricos e inicia los contadores de la nueva en cero.

<a id="fase-07"></a>

## M07 · PvP voluntario

Permitir competir por habilidad y objetivos conservando una ruta segura de progresión PvE.

**Demo de salida.** Se completan un duelo, una arena y una batalla por dos balizas. Un observador PvE cruza el mapa y conserva su protección.

### [M07.01 · Aceptar un duelo](https://github.com/GammaYoshimura/wow2d/issues/94)

Requiere [M02.13](https://github.com/GammaYoshimura/wow2d/issues/35), [M06.02](https://github.com/GammaYoshimura/wow2d/issues/75).

- **Godot.** Mostrar retador, cuenta atrás, rendición y fin de duelo a una vida.
- **Servidor.** Exigir consentimiento mutuo, arbitrar resultado e invalidar daño de terceros contra participantes protegidos.
- **Aceptación.** Rechazar conserva la protección. Aceptar permite un vencedor y devuelve a ambos al mundo con vida.

### [M07.02 · Elegir un bando de frontera](https://github.com/GammaYoshimura/wow2d/issues/95)

Requiere [M07.01](https://github.com/GammaYoshimura/wow2d/issues/94), [M03.08](https://github.com/GammaYoshimura/wow2d/issues/43).

- **Godot.** Mostrar ambos bandos y confirmar cómo afecta la elección a los encuentros de frontera.
- **Servidor.** Guardar afiliación PvP separada de la reputación PvE y resolver aliados y rivales.
- **Aceptación.** Dos personajes con igual reputación PvE pueden elegir bandos opuestos y conservar sus misiones.

### [M07.03 · Cruzar la frontera en paz](https://github.com/GammaYoshimura/wow2d/issues/96)

Requiere [M07.02](https://github.com/GammaYoshimura/wow2d/issues/95), [M03.05](https://github.com/GammaYoshimura/wow2d/issues/40).

- **Godot.** Señalar zona segura o de conflicto y permitir optar al combate mediante una confirmación explícita.
- **Servidor.** Evaluar bandera voluntaria, zona, facción y temporizador de salida al resolver cada ataque.
- **Aceptación.** Un observador sin bandera cruza entre dos rivales y permanece ileso incluso ante sus ataques de área.

### [M07.04 · Una arena de dos contra dos](https://github.com/GammaYoshimura/wow2d/issues/97)

Requiere [M07.03](https://github.com/GammaYoshimura/wow2d/issues/96), [M05.04](https://github.com/GammaYoshimura/wow2d/issues/52).

- **Godot.** Mostrar preparación, portones, marcador y salida tras la ronda.
- **Servidor.** Distribuir cuatro participantes en dos equipos, cerrar plantilla y resolver victoria, empate o abandono.
- **Aceptación.** Cuatro jugadores terminan una arena. Abandonar durante otra cierra la ronda una sola vez.

### [M07.05 · Rivales de nivel parecido](https://github.com/GammaYoshimura/wow2d/issues/98)

Requiere [M07.04](https://github.com/GammaYoshimura/wow2d/issues/97), [M05.09](https://github.com/GammaYoshimura/wow2d/issues/57).

- **Godot.** Mostrar rango de búsqueda, espera y posibilidad de retirarse antes del emparejamiento.
- **Servidor.** Emparejar por tramo de nivel y rating, ensanchando el margen de rating con el tiempo.
- **Aceptación.** Con seis fichas de prueba, cuatro compatibles reciben partida. Cancelar la cola retira la ficha restante elegida.

### [M07.06 · Las balizas del estuario](https://github.com/GammaYoshimura/wow2d/issues/99)

Requiere [M07.03](https://github.com/GammaYoshimura/wow2d/issues/96), [M05.04](https://github.com/GammaYoshimura/wow2d/issues/52).

- **Godot.** Mostrar dos puntos capturables, ocupación, equipo propietario y puntuación.
- **Servidor.** Crear un campo 5 contra 5, detener captura disputada y sumar puntos por control hasta el límite.
- **Aceptación.** Una baliza disputada no avanza. Controlar ambas acelera el marcador y la partida produce un solo ganador.

### [M07.07 · Honor que se puede gastar](https://github.com/GammaYoshimura/wow2d/issues/100)

Requiere [M07.05](https://github.com/GammaYoshimura/wow2d/issues/98), [M07.06](https://github.com/GammaYoshimura/wow2d/issues/99), [M08.08](https://github.com/GammaYoshimura/wow2d/issues/91).

- **Godot.** Mostrar honor, clasificación y coste de un estandarte cosmético.
- **Servidor.** Liquidar honor y rating a partir de resultados únicos y guardar la compra del estandarte.
- **Aceptación.** Reentregar el resultado de una partida conserva saldo y rating. Comprar el estandarte lo añade a la colección.

### [M07.08 · Revisar una partida disputada](https://github.com/GammaYoshimura/wow2d/issues/101)

Requiere [M07.07](https://github.com/GammaYoshimura/wow2d/issues/100), [M06.10](https://github.com/GammaYoshimura/wow2d/issues/83).

- **Godot.** Reportar desde el marcador y consultar la resolución disponible para el jugador.
- **Servidor.** Asociar caso, participantes, eventos autoritativos y señales de inactividad. Registrar decisión y revisión de sanción.
- **Aceptación.** Un moderador reconstruye una captura, distingue a un observador protegido y revierte una sanción de prueba con rastro de auditoría.

<a id="fase-09"></a>

## M09 · Operación y lanzamiento

Publicar cambios de contenido y atender a los jugadores mientras el mundo sigue progresando.

**Demo de salida.** En un ensayo de dos semanas se abre y cierra un evento, rota un objetivo, se aplica un parche y se restaura una copia con comprobaciones jugables.

### [M09.01 · El tablón de novedades](https://github.com/GammaYoshimura/wow2d/issues/102)

Requiere [M03.12](https://github.com/GammaYoshimura/wow2d/issues/47).

- **Godot.** Leer anuncios por idioma y ver la hora local de inicio y fin de un evento.
- **Servidor.** Publicar noticias versionadas con ventanas UTC y registrar la versión de contenido servida.
- **Aceptación.** Con reloj de prueba el anuncio aparece al abrirse la ventana y se archiva al terminarla.

### [M09.02 · La fiesta de la cosecha](https://github.com/GammaYoshimura/wow2d/issues/103)

Requiere [M09.01](https://github.com/GammaYoshimura/wow2d/issues/102), [M04.11](https://github.com/GammaYoshimura/wow2d/issues/73).

- **Godot.** Decorar el vado y ofrecer un encargo de recogida durante la fiesta.
- **Servidor.** Activar NPC, decoración y misión mediante un paquete de datos validado y reversible.
- **Aceptación.** Publicar y retirar el paquete con el servidor en marcha. El personaje conserva lo ya cobrado después del cierre.

### [M09.03 · Calendario diario y semanal](https://github.com/GammaYoshimura/wow2d/issues/104)

Requiere [M09.02](https://github.com/GammaYoshimura/wow2d/issues/103), [M08.10](https://github.com/GammaYoshimura/wow2d/issues/93).

- **Godot.** Reunir objetivos vigentes en un calendario con reinicio legible y estado de cobro.
- **Servidor.** Coordinar ciclos diario, semanal y de temporada y definir el tratamiento de entregas pendientes al caducar.
- **Aceptación.** Simular un cambio de día y de semana simultáneo. Los objetivos debidos rotan y los premios previos permanecen.

### [M09.04 · Escaparate de cosméticos](https://github.com/GammaYoshimura/wow2d/issues/105)

Requiere [M09.03](https://github.com/GammaYoshimura/wow2d/issues/104), [M08.08](https://github.com/GammaYoshimura/wow2d/issues/91).

- **Godot.** Previsualizar y adquirir un tinte con fichas de temporada mostrando precio y titularidad.
- **Servidor.** Mantener catálogo con vigencia, deducción de fichas y concesión idempotente de apariencia.
- **Aceptación.** Dos confirmaciones conceden un tinte y descuentan su precio una vez. Su uso conserva los atributos de combate.

### [M09.05 · Pase de temporada (opcional)](https://github.com/GammaYoshimura/wow2d/issues/106)

Requiere [M09.04](https://github.com/GammaYoshimura/wow2d/issues/105).

- **Godot.** Ver tres niveles de una pista de recompensas gratuita y reclamar el cosmético alcanzado.
- **Servidor.** Persistir XP de temporada y premios por tramo. Archivar la pista al renovarla.
- **Aceptación.** Un personaje que alcanza el tercer tramo conserva sus premios al cambiar de temporada.

### [M09.06 · Escuchar a los jugadores](https://github.com/GammaYoshimura/wow2d/issues/107)

Requiere [M09.01](https://github.com/GammaYoshimura/wow2d/issues/102), [M06.10](https://github.com/GammaYoshimura/wow2d/issues/83).

- **Godot.** Responder una encuesta breve al salir de una mazmorra y abrir un caso de soporte desde el menú.
- **Servidor.** Guardar una respuesta por encuesta y cuenta y gestionar estado del caso y respuesta al jugador.
- **Aceptación.** Al reconectar se ve el caso abierto y la encuesta contestada. El equipo puede responder y cerrar el caso.

### [M09.07 · Aplicar y revisar una sanción](https://github.com/GammaYoshimura/wow2d/issues/108)

Requiere [M06.10](https://github.com/GammaYoshimura/wow2d/issues/83), [M07.08](https://github.com/GammaYoshimura/wow2d/issues/101).

- **Godot.** Mostrar motivo comunicable, alcance, fin y vía de revisión de un silencio o suspensión.
- **Servidor.** Aplicar permisos por alcance y caducidad y auditar decisiones del moderador.
- **Aceptación.** Un silencio temporal bloquea el envío y mantiene el acceso al juego. El reloj de prueba restablece el chat al expirar.

### [M09.08 · Un parche con jugadores dentro](https://github.com/GammaYoshimura/wow2d/issues/109)

Requiere [M09.02](https://github.com/GammaYoshimura/wow2d/issues/103), [M01.03](https://github.com/GammaYoshimura/wow2d/issues/10).

- **Godot.** Avisar del mantenimiento, salir en punto seguro y comunicar la versión necesaria al volver.
- **Servidor.** Drenar la zona, guardar personajes, aplicar migración compatible y ensayar el retorno a la versión previa.
- **Aceptación.** Durante un parche de prueba, dos actores vuelven con posición, inventario y misión correctos. Registrar duración de la interrupción.

### [M09.09 · Recuperar la aldea de ayer](https://github.com/GammaYoshimura/wow2d/issues/110)

Requiere [M09.08](https://github.com/GammaYoshimura/wow2d/issues/109), [M04.11](https://github.com/GammaYoshimura/wow2d/issues/73).

- **Godot.** Volver a entrar con una cuenta de ensayo y revisar personaje, correo y compras tras restaurar.
- **Servidor.** Restaurar copia y registro de transacciones en entorno aislado. Medir antigüedad recuperable y tiempo de recuperación.
- **Aceptación.** Comparar saldo, último identificador de compra y estado del encargo con el punto elegido. Anotar RPO y RTO observados.

### [M09.10 · Detectar un problema en directo](https://github.com/GammaYoshimura/wow2d/issues/111)

Requiere [M09.07](https://github.com/GammaYoshimura/wow2d/issues/108), [M09.09](https://github.com/GammaYoshimura/wow2d/issues/110).

- **Godot.** Mostrar aviso de servicio y acceso a soporte cuando una función esté degradada.
- **Servidor.** Alertar por retraso del tick, fallos de acceso y descuadre económico. Medir retención D1/D7, embudo del slice, actividad y circulación monetaria.
- **Aceptación.** Con datos de ensayo, un descuadre genera una alerta rastreable. Una cohorte conocida produce los valores D1/D7 calculados a mano.

### [M09.11 · Ensayo de apertura](https://github.com/GammaYoshimura/wow2d/issues/112)

Requiere [M09.03](https://github.com/GammaYoshimura/wow2d/issues/104), [M09.04](https://github.com/GammaYoshimura/wow2d/issues/105), [M09.06](https://github.com/GammaYoshimura/wow2d/issues/107), [M09.10](https://github.com/GammaYoshimura/wow2d/issues/111).

- **Godot.** Invitar a un grupo externo de prueba a recorrer aldea, mercado, mazmorra y evento con clientes exportados.
- **Servidor.** Mantener un mundo de ensayo durante catorce días, operar la rotación y registrar incidentes, responsables y recuperación.
- **Aceptación.** Cerrar con dos rotaciones semanales observadas, un hotfix y una restauración ensayados. Publicar métricas, incidencias abiertas y decisión argumentada de lanzamiento.

<a id="fase-10"></a>

## M10 · Más jugadores y más reinos

Ampliar capacidad por medición y preservar personajes, relaciones y economía al cruzar fronteras.

**Demo de salida.** Dos reinos completan una actividad compartida. Una migración conserva bienes y vínculos. Se compara la capacidad antes y después bajo la misma carga.

### [M10.01 · Medir la plaza llena](https://github.com/GammaYoshimura/wow2d/issues/113)

Requiere [M09.11](https://github.com/GammaYoshimura/wow2d/issues/112).

- **Godot.** Repetir una ruta de cámara y medir fluidez con 25, 50 y 100 avatares visibles.
- **Servidor.** Repetir la misma carga en Ubuntu con entradas grabadas, CPU y versión fijas. Medir tick, tráfico por jugador y cola de persistencia.
- **Aceptación.** Publicar la curva y el primer tramo que rebasa el presupuesto. Guardar la traza para comprobar mejoras posteriores.

### [M10.02 · Repartir bosque y cantera](https://github.com/GammaYoshimura/wow2d/issues/114)

Requiere [M10.01](https://github.com/GammaYoshimura/wow2d/issues/113), [M03.01](https://github.com/GammaYoshimura/wow2d/issues/36).

- **Godot.** Conservar HUD, grupo y posición al cambiar entre zonas ejecutadas en procesos distintos.
- **Servidor.** Mover una zona a un segundo proceso con concesión de propiedad y número de generación para descartar escrituras atrasadas.
- **Aceptación.** Detener al propietario anterior durante el traspaso. Cada personaje vuelve a un único proceso y se conservan sus objetos.

### [M10.03 · Abrir una segunda copia de zona](https://github.com/GammaYoshimura/wow2d/issues/115)

Requiere [M10.02](https://github.com/GammaYoshimura/wow2d/issues/114).

- **Godot.** Mostrar capa actual y permitir reunirse con el grupo en una copia con espacio.
- **Servidor.** Crear y retirar copias por ocupación manteniendo afinidad de grupo y puntos de retorno válidos.
- **Aceptación.** Al llenar una copia se crea otra. Vaciarla la retira y, al reconectar, el grupo llega a una capa válida.

### [M10.04 · Una cola entre reinos](https://github.com/GammaYoshimura/wow2d/issues/116)

Requiere [M10.03](https://github.com/GammaYoshimura/wow2d/issues/115), [M05.09](https://github.com/GammaYoshimura/wow2d/issues/57).

- **Godot.** Indicar reino y rol en la propuesta y regresar al mundo de origen al terminar.
- **Servidor.** Resolver identidades globales y componer grupos entre dos reinos mediante reserva de plaza con caducidad.
- **Aceptación.** Completar una mazmorra con dos reinos, regresar y conservar un único premio en el reino de cada jugador.

### [M10.05 · Mudarse conservando la mochila](https://github.com/GammaYoshimura/wow2d/issues/117)

Requiere [M10.04](https://github.com/GammaYoshimura/wow2d/issues/116), [M04.09](https://github.com/GammaYoshimura/wow2d/issues/71).

- **Godot.** Previsualizar destino y avisar de anuncios u operaciones pendientes antes de confirmar un traslado.
- **Servidor.** Congelar escrituras, liquidar pendientes según regla publicada, transferir datos con ID estable y conmutar propiedad.
- **Aceptación.** Interrumpir y reanudar una migración de prueba conserva saldo, piezas, logros y amistades sin copias jugables.

### [M10.06 · Una hermandad entre reinos](https://github.com/GammaYoshimura/wow2d/issues/118)

Requiere [M10.05](https://github.com/GammaYoshimura/wow2d/issues/117), [M06.09](https://github.com/GammaYoshimura/wow2d/issues/82).

- **Godot.** Mostrar reino junto al nombre y permitir apuntarse al mismo evento desde ambos lados.
- **Servidor.** Resolver permisos y membresía por ID global y reconciliar presencia entre reinos.
- **Aceptación.** Dos miembros en reinos distintos ven la misma cita. Al cambiar de rango, los permisos coinciden en ambos.

### [M10.07 · Una tormenta para todo el mundo](https://github.com/GammaYoshimura/wow2d/issues/119)

Requiere [M10.03](https://github.com/GammaYoshimura/wow2d/issues/115), [M03.11](https://github.com/GammaYoshimura/wow2d/issues/46), [M09.02](https://github.com/GammaYoshimura/wow2d/issues/103).

- **Godot.** Mostrar progreso global y convocar a un jefe de mundo en cada capa participante.
- **Servidor.** Agregar aportaciones por evento e ID, abrir jefes locales y liquidar objetivo global una vez.
- **Aceptación.** Dos capas cruzan juntas el umbral. Reenviar una aportación no cambia la suma y cada jugador elegible cobra una vez.

### [M10.08 · Construir una sala con módulos](https://github.com/GammaYoshimura/wow2d/issues/120)

Requiere [M10.01](https://github.com/GammaYoshimura/wow2d/issues/113), [M05.11](https://github.com/GammaYoshimura/wow2d/issues/59).

- **Godot.** Ensamblar entrada, combate y salida con piezas visuales reutilizables y conectores marcados.
- **Servidor.** Validar conectividad y generar encuentros desde semilla, presupuesto de amenaza y catálogo de módulos.
- **Aceptación.** Diez semillas fijadas producen recorridos con salida alcanzable. Repetir una semilla reproduce mapa y encuentros.

### [M10.09 · Elegir un reto adaptado](https://github.com/GammaYoshimura/wow2d/issues/121)

Requiere [M10.08](https://github.com/GammaYoshimura/wow2d/issues/120).

- **Godot.** Ofrecer una variante de dificultad para la expedición y anticipar sus modificadores al grupo.
- **Servidor.** Calcular la variante con reglas versionadas, fijarla al comenzar y ajustar la recompensa al nivel elegido.
- **Aceptación.** Grupos de niveles distintos eligen variante. Reequiparse a mitad del intento conserva dificultad y tabla de premio.

### [M10.10 · Probar dos guías de inicio](https://github.com/GammaYoshimura/wow2d/issues/122)

Requiere [M10.01](https://github.com/GammaYoshimura/wow2d/issues/113), [M01.13](https://github.com/GammaYoshimura/wow2d/issues/20).

- **Godot.** Presentar dos variantes del indicador de la primera misión conservando legibilidad y salida manual.
- **Servidor.** Asignar cohorte estable, registrar aceptación y finalización, y poder retirar la variante por versión.
- **Aceptación.** Un personaje conserva cohorte al reconectar. Un informe separa embudos y documenta el criterio de adopción.

### [M10.11 · Jugar con otras señales](https://github.com/GammaYoshimura/wow2d/issues/123)

Requiere [M02.11](https://github.com/GammaYoshimura/wow2d/issues/33), [M10.01](https://github.com/GammaYoshimura/wow2d/issues/113).

- **Godot.** Reasignar teclas, escalar HUD y combinar forma, contraste y sonido en señales de jefe.
- **Servidor.** Enviar tipo y momento de la mecánica con independencia del recurso audiovisual usado.
- **Aceptación.** Completar un jefe con sonido desactivado y controles reasignados. Al ampliar texto siguen accesibles combate, diario y botín.

### [M10.12 · Cambiar de idioma sobre la marcha](https://github.com/GammaYoshimura/wow2d/issues/124)

Requiere [M10.11](https://github.com/GammaYoshimura/wow2d/issues/123), [M09.01](https://github.com/GammaYoshimura/wow2d/issues/102).

- **Godot.** Cargar español e inglés por claves, aplicar plurales y ampliar paneles para textos largos.
- **Servidor.** Enviar IDs y parámetros traducibles y validar cobertura y texto de reserva al publicar contenido.
- **Aceptación.** Cambiar idioma con una misión activa conserva contador, nombres propios y recompensa. Un texto largo cabe en el diario.

### [M10.13 · Revisar anomalías de juego](https://github.com/GammaYoshimura/wow2d/issues/125)

Requiere [M10.01](https://github.com/GammaYoshimura/wow2d/issues/113), [M07.08](https://github.com/GammaYoshimura/wow2d/issues/101).

- **Godot.** Permitir que soporte explique una acción retenida y que el jugador consulte su caso.
- **Servidor.** Correlacionar eventos autoritativos, revisión humana y resultados históricos para evaluar falsos positivos.
- **Aceptación.** Un conjunto etiquetado de partidas y operaciones produce métricas por tipo de señal y una resolución revisable para cada caso de ensayo.

### [M10.14 · Ajustar la economía entre temporadas](https://github.com/GammaYoshimura/wow2d/issues/126)

Requiere [M10.07](https://github.com/GammaYoshimura/wow2d/issues/119), [M04.11](https://github.com/GammaYoshimura/wow2d/issues/73), [M09.10](https://github.com/GammaYoshimura/wow2d/issues/111).

- **Godot.** Publicar cambios de tasas y costes con fecha y vista previa de las nuevas condiciones.
- **Servidor.** Simular un ajuste acotado con series de oferta y demanda y aplicarlo de forma versionada al abrir la temporada.
- **Aceptación.** Comparar una semana simulada antes y después. Los anuncios existentes conservan sus términos y las nuevas ventas usan la tasa publicada.

### [M10.15 · Ampliar la banda a veinte (opcional)](https://github.com/GammaYoshimura/wow2d/issues/127)

Requiere [M08.07](https://github.com/GammaYoshimura/wow2d/issues/90), [M10.01](https://github.com/GammaYoshimura/wow2d/issues/113), [M10.04](https://github.com/GammaYoshimura/wow2d/issues/116).

- **Godot.** Ofrecer cuatro subgrupos de cinco y distribuir las marcas del Observatorio sin tapar la arena.
- **Servidor.** Parametrizar plazas y mecánicas simultáneas para veinte conservando un registro por participante y jefe.
- **Aceptación.** Veinte personajes de dos reinos completan al Cartógrafo. Comparar con diez los tiempos de tick, legibilidad de marcas y veinte resoluciones individuales de botín.

## Cierre de fase

1. Recorrer la demo de salida con un cliente exportado y el servidor de esa versión en Ubuntu 26.04. Desde M00, usar dos conexiones reales para las comprobaciones compartidas. Añadir cuentas o clientes de carga cuando lo pida la fase.
2. Ejecutar las pruebas críticas acumuladas y comprobar al menos un personaje de la fase anterior cuando haya persistencia. En recompensas o compraventa, reconectar y repetir la última intención debe conservar el resultado.
3. Anotar versión de cliente, servidor y contenido, escenario, participantes, métricas y defectos conocidos. Conservar en la issue final de la fase una secuencia que otra persona pueda repetir. En las fases jugables con observadores externos, registrar también dónde necesitaron ayuda.
4. Comparar las mediciones con los objetivos de juego. Si un presupuesto cambia, dejar el valor observado, el nuevo objetivo y su motivo en este roadmap. Cerrar el milestone de GitHub al pasar su demo y resolver todas sus issues obligatorias. Las ampliaciones opcionales se pueden aplazar dejando su decisión registrada.

## Riesgos y señales para decidir

| Si durante la prueba ocurre esto… | Decisión ligada a una entrega |
| --- | --- |
| Los jugadores completan la caza sin cambiar de posición ni habilidad. | Volver a M02.11 y revisar tiempo de anticipación y geometría del ataque antes de diseñar el siguiente jefe. |
| Quien cura pierde al tanque entre tantos personajes. | Probar selección y salud desde el panel de M05.03 con tres participantes antes de ampliar el grupo. |
| Dos clientes terminan con el mismo objeto único o falta oro. | Mantener abierta la issue de la operación y verificar custodia, transacción y recibo con M04.06–M04.11. |
| Diseñar la segunda mazmorra exige modificar el código de la primera. | Revisar el catálogo de encuentros en M05.10. Una nueva sala debería poder reutilizar activadores, fases y recompensas. |
| La plaza se ralentiza mientras la zona vecina permanece vacía. | Reproducir M10.01 y comparar coste de simulación, replicación y persistencia. Usar la causa medida al elegir distribución o copias. |

## ai_handoff

**Encargo para la próxima sesión.** Trabaja sobre `GammaYoshimura/wow2d`. Para iniciar la implementación, abre **M00.01 · La plaza y el pozo**. Su resultado es una escena de la plaza que se puede abrir y comparar con el mapa de datos. Para reanudar más adelante, consulta primero la rama principal, este roadmap, las issues abiertas y las PR en curso. Reutiliza la rama o PR del micromilestone si ya existe. [Primera issue](https://github.com/GammaYoshimura/wow2d/issues/1) · [PR del proyecto](https://github.com/GammaYoshimura/wow2d/pulls)

### Ciclo de una entrega

1. **Elegir.** Si el usuario indicó un ID, parte de esa ficha. En otro caso, sigue la ruta del índice y elige el primer ID pendiente con dependencias terminadas. «Requiere» indica dependencias directas. Los tres elementos marcados como opcionales se planifican cuando el equipo decide activar la ampliación. Confirma el estado real en GitHub y en el código integrado.
2. **Acotar.** Reproduce el punto de partida. Copia en la PR o issue el escenario de aceptación, el resultado inicial y lo que el jugador podrá hacer al terminar. Para funcionalidades de red, especifica quién envía la intención, quién decide el resultado y dónde se guarda.
3. **Implementar.** Partir de la rama principal actualizada y trabajar en una rama `mm/<id>-<tema>`. Implementar la porción de cliente, backend y contenido que pide la ficha. En las primeras fichas un contrato de datos o una escena comprobable constituyen la parte entregable. Usar arte temporal, unidades explícitas e IDs estables. Registrar aquí cualquier cambio de contrato, dependencia o alcance que afecte a la siguiente entrega.
4. **Probar.** Recorrer la prueba de la ficha desde su entrada normal. Automatizar las reglas críticas en el componente que las decide. Para Go, ejecutar `go test ./...` desde `server/` cuando exista su módulo. En Godot, importar el proyecto con `godot --headless --path client --import` cuando exista `project.godot`, ejecutar las pruebas de escena disponibles y hacer la demo interactiva si intervienen movimiento, UI o legibilidad. La importación comprueba recursos. La prueba jugable aporta la evidencia de comportamiento. Adjuntar comando o pasos, datos usados, esperado y observado.
5. **Documentar y subir al GitHub.** Mantener **una PR identificable por micromilestone**. Incluir su ID en rama, commits y título. Subir la rama tras cada entrega y abrir o actualizar la PR dirigida a `main`. Incluir `Closes #<número real>`, resultado de aceptación, pruebas, compatibilidad y una captura o traza si ayuda a reproducirlo. Añadir en el registro de este roadmap la fila con ID, PR y resultado antes de integrar. La PR puede contener varios commits del mismo ID.
6. **Cerrar y relevar.** Verificar que la rama y la PR son visibles en el repositorio correcto, respetar las comprobaciones configuradas y confirmar que la integración en `main` cierra la issue. Si sigue abierta tras integrar, enlazar el cambio y cerrarla con la evidencia. Si fallan pruebas, falta publicar o la PR sigue en revisión, anotar el punto exacto y dejar la entrega en curso. En la siguiente sesión, comparar el registro con la issue y la PR antes de elegir otro ID.

**Ejemplo de publicación para M00.01.** Los comandos usan la primera issue ya creada. Ejecutar la preparación con árbol de trabajo revisado. Tras implementar, seleccionar para el commit los archivos de esa entrega y comprobar el diff preparado. Crear el cuerpo de la PR en `.git/m00.01-pr.md` con `Closes #1`, el resultado de abrir la plaza y las coordenadas contrastadas.

```sh
git switch main
git pull --ff-only origin main
git switch -c mm/m00.01-plaza
# Tras implementar y probar M00.01, preparar sus dos carpetas.
git add -- client/ content/
git diff --cached --stat
git commit -m "M00.01 · Añade la plaza y su mapa de colisión"
git push -u origin mm/m00.01-plaza
gh pr create --repo GammaYoshimura/wow2d --base main --head mm/m00.01-plaza --title "M00.01 · La plaza y el pozo" --body-file .git/m00.01-pr.md
```

**Nota de relevo para copiar en la issue o PR.** Completar los datos reales al terminar la sesión. Con una PR abierta ya se dispone de su URL para añadir la fila al roadmap y subir esa actualización a la misma rama.

```md
- Entrega e issue vinculada
- Estado actual y enlace a la PR o commit publicado
- Acción que ya puede hacer el jugador
- Cambio autoritativo, datos persistentes y compatibilidad
- Prueba ejecutada, resultado observado y evidencia
- Métrica relevante o motivo por el que todavía no aplica
- Pendiente concreto, punto para reproducirlo y siguiente ID habilitado
```

### Registro de implementación

En la publicación inicial, las **127 fichas** son trabajo planificado. Esta tabla recoge el resultado de cada entrega integrada. Cada PR incorpora su fila al roadmap como parte del cambio.

| Entrega | Issue y PR | Resultado de la prueba o decisión | Siguiente ID |
| --- | --- | --- | --- |
| Plan inicial | [Backlog del proyecto](https://github.com/GammaYoshimura/wow2d/milestones) | Se ha publicado el plan de trabajo. La primera prueba jugable corresponde a la plaza. | M00.01 |
| M00.01 | [#1](https://github.com/GammaYoshimura/wow2d/issues/1) · [PR #128](https://github.com/GammaYoshimura/wow2d/pull/128) | Godot 4.7.2 importó y ejecutó la escena. La prueba plaza_layout_test.gd verificó 32 × 32 casillas, 111 colisiones cuadradas, el pozo, los dos accesos y tres puntos de aparición contra el catálogo. | M00.02 |
| M00.02 | [#2](https://github.com/GammaYoshimura/wow2d/issues/2) · [PR #129](https://github.com/GammaYoshimura/wow2d/pull/129) | Prueba de Godot con entradas en 30 ticks por eje y diagonal. Verifica distancias equivalentes, parada al soltar, colisión en x=74 px y cámara limitada en ambos bordes. | M00.03 |
| M00.03 | [#3](https://github.com/GammaYoshimura/wow2d/issues/3) · [PR #130](https://github.com/GammaYoshimura/wow2d/pull/130) | Pasó go test ./... y la prueba Godot contra el proceso Go local. Dos clientes recibieron guest-1 (464, 592) y guest-2 (528, 592). Una revisión incompatible mostró su motivo en pantalla. | M00.04 |
