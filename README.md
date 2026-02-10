# 🧾 Programa PB0EC319 — Incremento de Salario a Empleados

## 📘 Descripción

El programa **PB0EC319** realiza un **cruce de ficheros** entre el **maestro de empleados** y un **fichero secuencial de subidas salariales**, con el objetivo de **actualizar los salarios** de los empleados correspondientes.  
El resultado es un **nuevo fichero de salida**, copia del maestro original, pero con los salarios incrementados para los empleados afectados.

Además, el programa **genera mensajes de control e inconsistencias**, avisando de cualquier subida cuyo empleado no exista en el maestro.

---

## 🎯 Objetivo

- Leer el **maestro de empleados** y el **fichero de subidas**.  
- Comparar ambos registros (matching 1:1).  
- Actualizar el salario en caso de coincidencia de clave.  
- Mantener los registros no modificados.  
- Detectar y reportar inconsistencias (subidas sin empleado).  
- Generar un **fichero de salida actualizado** y un **informe resumen** con los contadores de registros procesados.

---

## ⚙️ Tipo de proceso

**Batch / Matching 1:1**

---

## 📥 Entradas

| Fichero | Descripción |
|----------|--------------|
| **MAESTRO** | Fichero maestro de empleados (Indexed / Sequential Read). |
| **SUBIDAS** | Fichero secuencial con incrementos de salario. |
| **DATOS DEL SISTEMA** | Fecha y hora de ejecución (aceptadas desde el sistema). |

---

## 📤 Salidas

| Fichero | Descripción |
|----------|--------------|
| **SALIDA** | Copia del maestro con los salarios actualizados. |
| **INFORME (pantalla)** | Contadores de registros leídos y grabados. <br> Mensajes de error o inconsistencias. |

---

## 🧩 Estructuras principales

### **Maestro de empleados (`MAESTRO`)**

CLAVE (X(5))
FILLER X(95)

### **Fichero de subidas (`SUBIDAS`)**

CODIGO (X(5))
SUBIDA (S9(9) PACKED-DECIMAL)
FILLER ...


### **Fichero de salida (`SALIDA`)**
Copia del maestro con salario actualizado.

---

## 🔄 Lógica de procesamiento

1. **Inicio del programa**
   - Muestra fecha y hora de ejecución.
   - Abre los tres ficheros: `MAESTRO`, `SUBIDAS` y `SALIDA`.
   - Valida los códigos de estado de apertura (File Status).

2. **Cruce de ficheros**
   - Si la `CLAVE` del maestro coincide con el `CODIGO` del fichero de subidas → **incrementa salario**.
   - Si la `CLAVE` del maestro es menor → **mantiene registro**.
   - Si la `CLAVE` del maestro es mayor → **inconsistencia** (subida sin empleado).

3. **Fin del proceso**
   - Muestra resumen con contadores:
     - Registros leídos del maestro
     - Registros leídos del fichero de subidas
     - Registros grabados en salida
   - Indica si hubo errores o ejecución correcta.

---

## 🧮 Contadores

| Contador | Descripción |
|-----------|--------------|
| `CTR-LEIDOS-MAESTRO` | Número de registros leídos del maestro. |
| `CTR-LEIDOS-SUBIDAS` | Número de registros leídos del fichero de subidas. |
| `CTR-GRABADOS` | Número total de registros grabados en el fichero de salida. |

---

## 🚨 Manejo de errores

- **FS-ERROR1 / FS-ERROR2 / FS-ERROR3:** Códigos de error de acceso a ficheros.  
- **ERRORES-SWITCH:** Señaliza error general durante ejecución.  
- **EMPTY-FILE-SWITCH:** Indica fichero de subidas vacío.  
- En caso de error grave, el programa:
  - Muestra mensajes de advertencia (`A T E N C I O N / ERRORES`).
  - Finaliza con `RETURN-CODE 1001`.

---

## 🧑‍💻 Autoría

- **Autor:** ESTIBALIZ (ORIZON)  
- **Fecha de escritura:** Octubre 2025  
- **Lenguaje:** COBOL  
- **Programa ID:** `PB0EC319`

---

## 🚀 Ejecución del programa COBOL

### Archivo JCL: INCSAL.JCL

```jcl
//INCSAL     JOB (ACCT),'INCREMENTO SALARIO',CLASS=A,MSGCLASS=X,
//             NOTIFY=&SYSUID
//*
//STEP1      EXEC PGM=PB0EC319
//*
//MAESTRO    DD  DSN=USER.MAESTRO.EMPLEADOS,DISP=SHR
//SUBIDAS    DD  DSN=USER.SUBIDAS,DISP=SHR
//SALIDA     DD  DSN=USER.MAESTRO.SALIDA,DISP=(NEW,CATLG,DELETE),
//             SPACE=(CYL,(5,1)),UNIT=SYSDA
//SYSOUT     DD  SYSOUT=*
//SYSPRINT   DD  SYSOUT=*
//SYSIN      DD  DUMMY

```
## 🧾 Ejemplo de ejecución

COMIENZA EL PROGRAMA PB0EC319
HOY ES: 2025-10-18
SON LAS: 14:37:52:03

*** EJECUCION OK ***

LEIDOS MAESTRO 500
LEIDOS SUBIDAS 40
GRABADOS 500
FIN DEL PROGRAMA PB0EC319
