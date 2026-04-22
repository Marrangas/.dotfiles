dotdotdot ... or with the gliph ...

- [ ] firebox config
      https://github.com/sobolevn/dotfiles/blob/master/firefox/user-overrides.js
- [ ] global configurations
- [ ] ansible deployment
- [ ] ## nvim
- [ ] local scripts
- [ ] better secrets handling with cli

- que:: gestion y documentacion de mis configuraciones
- por-que:: [[backup]]
  - razon:: (induccion|deduccion|abduccion = empirismo)
  - autoridad:: tener las herramientas afiladas y conocerlas suele ayudar
  - pragmatismo:: poder implementarlos, comprenderlos y editralos (consecuencias)
  - axiologia:: saber que puedo exponerlos y tener ideas propias (valores)
  - experiencias:: se me han ido rompiendo y no tengo un registro en guit de lo que
    he hecho (hacer un bisect o al menos tenerlos limpios)
  - emociones:: me gusta sentirme a gusto y pensar que puedo mejorarjb
- 5 porque:
  - porque quiero hacer un backup
  - porque no me funciona el markdown
  - porque no conoxco bien mis herramientas ni lo he inventariado ni testeado
  - porque solo he cortapegado o he redactado un video
  - porque quiero intentar tener criterio

- para-que:: (motivo) para que hago este proyecto no para que existen, el motivo
- para explorar las nuevas herramientas y ver como poder trabajar con ellas
- para comprender lo que ya tengo una capa mas profunda
- para inventariar y revisar lo que sigo sin comprender o lo que se me ha olvidado
- me ayuda a filosofar sobre los principios
- quien:: (responable) se puede crear una comunidad, lo podria llegar a utilizar para
  alguna otra persona?
- como::(accion)

```quote
verbosity vs great defauls
```

- safe load some configs depending on the variables
  - [ ] edit it as if it were my own mac if it is a computer mac and it is intended
        as a workstation

## basic tools

- [[shell]] todo el mundo habla de tener esta shell o la otra shell o la shell de al
  lado, a la hora de la verdad obviamos el fundamento de un ordenador en el sentido
  en el que podemos operar con el de formas muy prácticas con comandos sencillos. La
  llegada de la IA, estupidifica a las personas hasta el punto en el que no somos
  capaces de tener en cuenta las variables que nosotros mismos buscamos, tal que no
  podemos evaluar la competitud o calidad del trabajo que estamos exigiendo... Hay
  que saber hacer buenas preguntas y valorar si las respuestas que te están dando son
  las correctas o te las están intentando liar: Hablar con una ia como forma de
  evaluar tu capacidad de liderazgo y de expresión oral a la vista queda que la gran
  mayoría del trabajo está en poder ser preciso y dar el suficiente contexto para
  tener el resultado que el emisor quiere dar

- [[window-manager]] & [[multiplexer]] iconos al alcance de todo todos? de todas
  formas conocer en una pantalla en negro todas y cada una de las herramientas será
  mucho más facil en el caso de un multiplexor, lo que permite es tener un espacio
  con una organzación virutal tal y como cada uno desee: herramientas y estructuras
  de datos para la vida diaria (3 niveles tope):
  - session (contenedor) n
  - tab 2-5 aprox
  - split 3

- [[editor]] emacs vs vim... I am fan of using native aps for what I do. There is
  this thing of trying the perfect workflow, the perfect set of unified tools. In my
  experience you need to know that there are some things that are unreconcileable,
  just use something self suficient that does not add aditional overhead for your
  personal use case example:
  - using vim for something that needs a ui (I just want a simple and fast client)
  - using terraform to automate dynamic eleents instead of the api
  - templates in obsidian vs snippets in vim...

- [[personal-defaults]] know your variables and what exactly you want to achieve

- [[syntax-highlighters]]

- [[experiments]]
- [[archives]]
- [[automations]]

- manage what do I need and what is my context
  - el estilo en general de la instancia me dice si el entorno es dev, test, pro....

- functional syntax tree sitter (parser and lsp)
  - mixed documentations and linking with the power of multilsp
  - manage all the things with a database
  - style inside with the help of the sintax
  - linting
  - formatting

- navegation and code actions
  - netrw & find command
  - picker fuzzy finder with actions
  - actions

- documentation

- diagnostics and debugging
  - dap
  - diagnostics

- new tools: ia...
  - quickfix vs location vs the fucking pickers...
  - diagnostics and bash
  - ia gemini and others

6. terminar el formateo en markdown
7. lsp setup del resto de los lenguajes

- terraform
- ansible
- yaml
- html, con htmx y javascript
- css, con tailwind
- python
- go
- bash
- lua
- markdown

## style

- parece una tonteria pero preocuparse por la accesibilidad suele ser señal de que te
  importan otras coasas, de tener ua expectativa más alta de lo que deberia esta
  hechho
  - sin estilo se perciben las cosas por lo que son... no tengas demasiado estilo
  - saber como funciona algo (lsp) o como se construye hace valorar lo que vemos
  - el estilo permite una estructura informal para los humanos, de la misma forma que
    lo lee un ordenador, grouping [[gestalt]]
  - poder distinguir el entorno
  - TODO: depende de la variable del entorno... debe de ser de un color de fondo...
    (shell, cat, vim)
- lsp
- linters
- formaters
- debug
- diccionarios (hacking y otras listas que no son para llm sino brute force...)

## futures

- managing and exposign the dotfiles [[ansible-dotfiles]]
  - encapsulation of dotfiles
  - management for each resource
  - bidirectional sing or (central repository with my own permissions) (distributed
    management and async configurations with locking)

- [[2022]] some of this config was born, i versioned it bu, always hapens somethin
- [[2026]] 1st rewrite this time trying not to copy and paste

- restaurar las ideas antiguas para tener el registro y la evolucion (how to
  autodocument? diagramming adn inventories... maybe they are json) or that is..
  exposing the veriables to a graph database with objects... (markdowns) => { the
  same pattern as the mongo is being repeated for my one and only personal system }
