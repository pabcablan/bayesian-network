# 🤖 Red Bayesiana para Diagnóstico de Servidores

![CLIPS Version](https://img.shields.io/badge/language-CLIPS-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/status-finished-success)


## 📝 Descripción General

Este proyecto implementa una **Red Bayesiana en CLIPS** con el propósito de diagnosticar fallas en servidores de un Centro de Procesamiento de Datos (CPD). Este modelo probabilístico permite identificar y analizar las causas más probables de problemas en los servidores, facilitando un mantenimiento más eficiente y una resolución más rápida de incidencias.

La red modela las dependencias entre diferentes componentes y estados de un servidor, como la CPU, la memoria, la temperatura y los servicios de software, para inferir la causa raíz de una falla a partir de la evidencia observada.


## 🕸️ Estructura de la Red Bayesiana

La siguiente imagen muestra el grafo acíclico dirigido que representa las relaciones de dependencia entre las variables del sistema:

![Estructura Red](https://i.imgur.com/Fm6tFN6.png)

Cada nodo representa una variable aleatoria (p. ej., "Error en la memoria RAM", "Alta Carga de CPU") y las aristas indican las relaciones causales entre ellas. Para una descripción detallada de cada nodo y sus probabilidades, consulta el informe completo.


## 📂 Estructura del Proyecto

El proyecto se compone de los siguientes archivos:

| Archivo | Descripción |
| :--- | :--- |
| [`LICENSE`](LICENSE) | Archivo de licencia del proyecto (MIT). |
| [`README.md`](README.md) | Documentación del proyecto |
| [`expertSystemForCPDHandling.clp`](expertSystemForCPDHandling.clp) | Implementación en CLIPS |
| [`expertSystemForCPDHandling.txt`](expertSystemForCPDHandling.txt) | Código en formato de texto|
| [`reportBayesianNetworkCdp.pdf`](reportBayesianNetworkCdp.pdf) | Informe detallado del proyecto |

## 📦 Requisitos

Para ejecutar el sistema experto bayesiano necesitas:

- **CLIPS**  
  Descarga e instala CLIPS desde su [página oficial](http://www.clipsrules.net/Downloads.html).  
  Compatible con Windows, Linux y macOS.

- **Archivos del proyecto**  
  - `expertSystemForCPDHandlingUncertainty.clp`  
  - (Opcional) Consulta `README.md` y el informe `reportBayesianNetworkCdp.pdf` para más detalles.

> **No se requieren librerías ni configuraciones adicionales.**  
> Todo el funcionamiento es local y autónomo mediante la consola de CLIPS.


## ⚙️ Instalación

Para clonar este repositorio en tu máquina local, ejecuta:

```bash
https://github.com/pabcablan/bayesian-network
cd bayesian-network
```


## 🚀 Ejecución

Para realizar una consulta, sigue este flujo de comandos en la consola de CLIPS:

1.  **Carga el sistema y reinicia el entorno.** Esto prepara el motor para una nueva consulta.
    ```clips
    (load "expertSystemForCPDHandlingUncertainty.clp")
    (reset)
    ```

2.  **Introduce la evidencia (hechos observados) y tu consulta.**
    Por ejemplo, para saber la probabilidad de `Caida_Servidor` si sabemos que la `CPU_Alta` es `TRUE`:
    ```clips
    ; Evidencia: se ha detectado una alta carga en la CPU.
    (assert (evidencia (nombre CPU_Alta) (valor TRUE)))

    ; Consulta: ¿cuál es la probabilidad de que el servidor se caiga?
    (assert (consulta (nombre Caida_Servidor) (valor TRUE)))
    ```

3.  **Ejecuta el motor de inferencia** para obtener el resultado.
    ```clips
    (run)
    ```

⚠️ **Importante**: Para realizar una nueva consulta con distinta evidencia, debes ejecutar `(reset)` de nuevo antes de introducir los nuevos hechos.


## 📊 Resultados

El sistema puede calcular la probabilidad de una falla dadas ciertas evidencias. Por ejemplo, ante un reinicio inesperado y una temperatura alta, la probabilidad de que el servidor se caiga es de aproximadamente **0.94813**.

![Resultados](https://i.imgur.com/ZlCQw4r.png)

Para un análisis más detallado y otros casos de uso, consulta el informe [`reportBayesianNetworkCdp.pdf`](reportBayesianNetworkCdp.pdf).

## 📄 Licencia

Este proyecto está licenciado bajo la licencia MIT. Consulta el archivo `LICENSE` para obtener más detalles.

**Nota**: Este proyecto fue desarrollado como trabajo académico para la asignatura **Inteligencia Artificial para Ciencia de Datos** de la [Universidad de Las Palmas de Gran Canaria](https://www.ulpgc.es/).
