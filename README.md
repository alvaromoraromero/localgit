# localgit
Script en bash de Windows (.bat) para gestionar un repositorio "bare" git remoto en un USB

Para omitir la pregunta para introducir la ruta contenedora de repositorios en el USB, se puede dar un valor fijo a la variable `localgitpath`. Ten en cuenta que si la letra de unidad del USB cambia, será necesario actualizar el valor fijado de la variable.

Cuando se inicia el script, comprueba si la ruta desde la que se ha iniciado tiene un repositorio de git inicializado.
En caso negativo o que se indique que no se desea utilizar dicho repositorio, buscará y listará los repositorios en `C:\ProgramData\workspace`. Puedes cambiar esta ruta modificando el script manualmente.

Una vez seleccionado un repositorio, siempre mostrará una pantalla de confirmacion en la que se indica la ubicación del repositorio local y la que utilizará en el USB. Si existe, mostrará el menú principal y en caso contrario el menú de inicio de clonado en USB.

Una vez se ha clonado un repositorio en un USB siempre mostrará el menú principal para dicho repositorio, hasta que se elimine o se renombre.

> [!TIP]
> Coloca este archivo en una ubicación que tengas en la variable PATH.
> De esta forma, podrás ejecutar el comando `localgit` desde cualquier ubicación.