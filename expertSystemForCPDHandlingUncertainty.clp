;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;						Estructura de Datos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Plantilla para consultas del usuario
(deftemplate consulta
	(slot nombre)
	(slot valor (default TRUE)))


;; Plantilla para evidencias introducidas por usuario
(deftemplate evidencia
	(slot nombre)
	(slot valor))


;; Estados actuales de síntomas observados
(deftemplate estado (slot nombre) (slot valor))

;; Plantillas para probabilidades
(deftemplate p-CPU
	(slot v)
	(slot p))

(deftemplate p-RAM
	(slot v)
	(slot p))

(deftemplate p-Disco
	(slot v)
	(slot p))

(deftemplate p-Temp
	(slot temp)
	(slot cpu)
	(slot p))

(deftemplate p-SO
	(slot so)
	(slot cpu)
	(slot disco)
	(slot p))

(deftemplate p-Reinicio
	(slot reinicio)
	(slot ram)
	(slot temp)
	(slot p))

(deftemplate p-Caida
	(slot caida)
	(slot reinicio)
	(slot so)
	(slot temp)
	(slot p))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;						Hechos iniciales
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deffacts inicial 

	;; Estados iniciales desconocidos al inicio
	(estado(nombre CPU_Alta)(valor desconocido))
	(estado(nombre Disco_Error)(valor desconocido))
	(estado(nombre RAM_Error)(valor desconocido))
    (estado(nombre Temp_Alta)(valor desconocido))
    (estado(nombre Reinicio)(valor desconocido))
	(estado(nombre SO_Inestable)(valor desconocido))
	
	;; Probabilidad de CPU Alta
	(p-CPU (v TRUE) (p 0.3))
	(p-CPU (v FALSE) (p 0.7))
	
	;; Probabilidad RAM Error
	(p-RAM (v TRUE) (p 0.15))
	(p-RAM (v FALSE) (p 0.85))
  
	;; Probabilidad Disco Error
	(p-Disco (v TRUE) (p 0.1))
	(p-Disco (v FALSE) (p 0.9))
  
	;; Probabilidad Temperatura Alta
	(p-Temp (temp TRUE) (cpu TRUE) (p 0.8))
	(p-Temp (temp TRUE) (cpu FALSE) (p 0.1))
	(p-Temp (temp FALSE) (cpu TRUE) (p 0.2))
	(p-Temp (temp FALSE) (cpu FALSE) (p 0.9))
	
	;; Probabilidad Sistema Operativo Inestable
	(p-SO (so TRUE) (cpu TRUE) (disco TRUE) (p 0.95))
	(p-SO (so TRUE) (cpu TRUE) (disco FALSE) (p 0.90))
	(p-SO (so TRUE) (cpu FALSE) (disco TRUE) (p 0.60))
	(p-SO (so TRUE) (cpu FALSE) (disco FALSE) (p 0.20))
	(p-SO (so FALSE) (cpu TRUE) (disco TRUE) (p 0.05))
	(p-SO (so FALSE) (cpu TRUE) (disco FALSE) (p 0.10))
	(p-SO (so FALSE) (cpu FALSE) (disco TRUE) (p 0.40))
	(p-SO (so FALSE) (cpu FALSE) (disco FALSE) (p 0.80))
	
	;; Probabilidad Reinicio
	(p-Reinicio (reinicio TRUE) (ram TRUE) (temp TRUE) (p 0.90))
	(p-Reinicio (reinicio TRUE) (ram TRUE) (temp FALSE) (p 0.75))
	(p-Reinicio (reinicio TRUE) (ram FALSE) (temp TRUE) (p 0.70))
	(p-Reinicio (reinicio TRUE) (ram FALSE) (temp FALSE) (p 0.10))
	(p-Reinicio (reinicio FALSE) (ram TRUE) (temp TRUE) (p 0.10))
	(p-Reinicio (reinicio FALSE) (ram TRUE) (temp FALSE) (p 0.25))
	(p-Reinicio (reinicio FALSE) (ram FALSE) (temp TRUE) (p 0.30))
	(p-Reinicio (reinicio FALSE) (ram FALSE) (temp FALSE) (p 0.90))
	
	;; Probabilidad Caida del Servidor
	(p-Caida (caida TRUE) (reinicio TRUE) (so TRUE) (temp TRUE) (p 0.98))
	(p-Caida (caida TRUE) (reinicio TRUE) (so TRUE) (temp FALSE) (p 0.95))
	(p-Caida (caida TRUE) (reinicio TRUE) (so FALSE) (temp TRUE) (p 0.85))
	(p-Caida (caida TRUE) (reinicio TRUE) (so FALSE) (temp FALSE) (p 0.75))
	(p-Caida (caida TRUE) (reinicio FALSE) (so TRUE) (temp TRUE) (p 0.70))
	(p-Caida (caida TRUE) (reinicio FALSE) (so TRUE) (temp FALSE) (p 0.50))
	(p-Caida (caida TRUE) (reinicio FALSE) (so FALSE) (temp TRUE) (p 0.30))
	(p-Caida (caida TRUE) (reinicio FALSE) (so FALSE) (temp FALSE) (p 0.01))
	(p-Caida (caida FALSE) (reinicio TRUE) (so TRUE) (temp TRUE) (p 0.02))
	(p-Caida (caida FALSE) (reinicio TRUE) (so TRUE) (temp FALSE) (p 0.05))
	(p-Caida (caida FALSE) (reinicio TRUE) (so FALSE) (temp TRUE) (p 0.15))
	(p-Caida (caida FALSE) (reinicio TRUE) (so FALSE) (temp FALSE) (p 0.25))
	(p-Caida (caida FALSE) (reinicio FALSE) (so TRUE) (temp TRUE) (p 0.30))
	(p-Caida (caida FALSE) (reinicio FALSE) (so TRUE) (temp FALSE) (p 0.50))
	(p-Caida (caida FALSE) (reinicio FALSE) (so FALSE) (temp TRUE) (p 0.70))
	(p-Caida (caida FALSE) (reinicio FALSE) (so FALSE) (temp FALSE) (p 0.99))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;				   Reglas y Funciones auxiliares
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Regla para actualizar la evidencia
(defrule set_evidencia
	?f <- (estado (nombre ?n1) (valor desconocido))
	?e <- (evidencia (nombre ?n2&:(eq ?n1 ?n2)) (valor ?v))
	=>
	(modify ?f (valor ?v))
	(retract ?e)
)

;; Función para devolver las posibles opciones de un estado
(deffunction opciones (?estado)
	(if (eq ?estado desconocido)
		then (create$ TRUE FALSE)
		else (if (eq ?estado TRUE)
			then (create$ TRUE)
            else (create$ FALSE)))
)

;; Función para calcular probabilidad de CPU Alta
(deffunction calc-prob-cpu (?valor)
	(bind ?resultado (find-fact ((?f p-CPU)) (eq ?f:v ?valor)))
	(if (neq ?resultado nil)
		then (fact-slot-value (nth$ 1 ?resultado) p)
		else 0.0)
)


;; Función para calcular probabilidad de RAM Error
(deffunction calc-prob-ram (?valor)
	(bind ?resultado (find-fact ((?f p-RAM)) (eq ?f:v ?valor)))
	(if (neq ?resultado nil)
		then (fact-slot-value (nth$ 1 ?resultado) p)
		else 0.0)
)

;; Función para calcular probabilidad de Disco Error
(deffunction calc-prob-disco (?valor)
	(bind ?resultado (find-fact ((?f p-Disco)) (eq ?f:v ?valor)))
	(if (neq ?resultado nil)
		then (fact-slot-value (nth$ 1 ?resultado) p)
		else 0.0)
)

;; Función para calcular probabilidad de Temperatura Alta
(deffunction calc-prob-temp (?temp ?cpu)
	(bind ?resultado (find-fact ((?f p-Temp))
				(and (eq ?f:temp ?temp) 
                     (eq ?f:cpu ?cpu))))
	(if (neq ?resultado nil)
		then (fact-slot-value (nth$ 1 ?resultado) p)
		else 0.0)
)

;; Función para calcular probabilidad de SO Inestable
(deffunction calc-prob-so (?so ?cpu ?disco)
	(bind ?resultado (find-fact ((?f p-SO)) 
				(and (eq ?f:so ?so) 
					(eq ?f:cpu ?cpu)
                    (eq ?f:disco ?disco))))
	(if (neq ?resultado nil)
		then (fact-slot-value (nth$ 1 ?resultado) p)
		else 0.0)
)

;; Función para calcular probabilidad de Reinicio
(deffunction calc-prob-reinicio (?reinicio ?ram ?temp)
	(bind ?resultado (find-fact ((?f p-Reinicio)) 
				(and (eq ?f:reinicio ?reinicio) 
                    (eq ?f:ram ?ram)
                    (eq ?f:temp ?temp))))
	(if (neq ?resultado nil)
		then (fact-slot-value (nth$ 1 ?resultado) p)
		else 0.0)
)

;; Función para calcular probabilidad de Caída del Servidor
(deffunction calc-prob-caida (?caida ?reinicio ?so ?temp)
	(bind ?resultado (find-fact ((?f p-Caida)) 
				(and (eq ?f:caida ?caida) 
                    (eq ?f:reinicio ?reinicio)
                    (eq ?f:so ?so)
                    (eq ?f:temp ?temp))))
	(if (neq ?resultado nil)
		then (fact-slot-value (nth$ 1 ?resultado) p)
		else 0.0)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;		 Cálculo para Obtencion de Probs de las Consultas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Funcion para calcular la prob de Caida de Servidor dado sintomas
(deffunction calc-inf-caida-servidor (?valor-objetivo)
	(bind ?sum_objetivo 0.0)
	(bind ?sum_total 0.0)

	;; Obtener los hechos de cada variable usando find-all-facts y nth$
	(bind ?cpu-fact  (nth$ 1 (find-all-facts ((?f estado)) (eq ?f:nombre CPU_Alta))))
	(bind ?ram-fact  (nth$ 1 (find-all-facts ((?f estado)) (eq ?f:nombre RAM_Error))))
	(bind ?disk-fact (nth$ 1 (find-all-facts ((?f estado)) (eq ?f:nombre Disco_Error))))
	(bind ?temp-fact (nth$ 1 (find-all-facts ((?f estado)) (eq ?f:nombre Temp_Alta))))
	(bind ?rein-fact (nth$ 1 (find-all-facts ((?f estado)) (eq ?f:nombre Reinicio))))
	(bind ?so-fact   (nth$ 1 (find-all-facts ((?f estado)) (eq ?f:nombre SO_Inestable))))

	(bind ?cpu_state  (fact-slot-value ?cpu-fact valor))
	(bind ?ram_state  (fact-slot-value ?ram-fact valor))
	(bind ?disk_state (fact-slot-value ?disk-fact valor))
	(bind ?temp_state (fact-slot-value ?temp-fact valor))
	(bind ?rein_state (fact-slot-value ?rein-fact valor))
	(bind ?so_state   (fact-slot-value ?so-fact valor))

	;; Generar las listas de valores según evidencia (o desconocido)
	(bind ?lista-cpu  (opciones ?cpu_state))
	(bind ?lista-ram  (opciones ?ram_state))
	(bind ?lista-disk (opciones ?disk_state))
	(bind ?lista-temp (opciones ?temp_state))
	(bind ?lista-rein (opciones ?rein_state))
	(bind ?lista-so   (opciones ?so_state))

	;; Enumerar sobre todas las combinaciones
	(foreach ?cpu ?lista-cpu
		(foreach ?ram ?lista-ram
			(foreach ?disk ?lista-disk
				(foreach ?temp ?lista-temp
					(foreach ?rein ?lista-rein
						(foreach ?so ?lista-so
							(foreach ?caida (create$ TRUE FALSE)
								(bind ?p_asig 
									(*	(calc-prob-cpu ?cpu)
										(calc-prob-ram ?ram)
										(calc-prob-disco ?disk)
										(calc-prob-temp ?temp ?cpu)
										(calc-prob-reinicio ?rein ?ram ?temp)
										(calc-prob-so ?so ?cpu ?disk)
										(calc-prob-caida ?caida ?rein ?so ?temp)
									)
								)
							(bind ?sum_total (+ ?sum_total ?p_asig))
							(if (eq ?caida ?valor-objetivo)
								then (bind ?sum_objetivo (+ ?sum_objetivo ?p_asig))      
							)
							)
						)
					)
				)
			)
		)
	)

	;; Calcular probabilidad posterior
	(bind ?posterior (/ ?sum_objetivo ?sum_total))

	;; Imprimir resultado con el valor TRUE o FALSE de la caída
	(printout t "La probabilidad de que el servidor caiga (" ?valor-objetivo ") dadas las evidencias observadas es: " (/ (round (* ?posterior 100000)) 100000) crlf)
)

;; Funcion para calcular la prob de Reinicio dado sintomas
(deffunction calc-inf-reinicio (?valor-objetivo)
	(bind ?sum_objetivo 0.0)
	(bind ?sum_total 0.0)
	
	;; Obtener los hechos de cada variable usando find-all-facts y nth$
	(bind ?cpu-fact  (nth$ 1 (find-all-facts ((?f estado)) (eq ?f:nombre CPU_Alta))))
	(bind ?ram-fact  (nth$ 1 (find-all-facts ((?f estado)) (eq ?f:nombre RAM_Error))))
	(bind ?temp-fact (nth$ 1 (find-all-facts ((?f estado)) (eq ?f:nombre Temp_Alta))))
	
	(bind ?cpu_state  (fact-slot-value ?cpu-fact valor))
	(bind ?ram_state  (fact-slot-value ?ram-fact valor))
	(bind ?temp_state (fact-slot-value ?temp-fact valor))
	
	;; Generar las listas de valores según evidencia (o desconocido)
	(bind ?lista-cpu  (opciones ?cpu_state))
	(bind ?lista-ram  (opciones ?ram_state))
	(bind ?lista-temp (opciones ?temp_state))
	
	;; Enumerar sobre todas las combinaciones
	(foreach ?cpu ?lista-cpu
		(foreach ?ram ?lista-ram
			(foreach ?temp ?lista-temp
				(foreach ?rein (create$ TRUE FALSE)
					(bind ?p_asig 
						(* 	(calc-prob-cpu ?cpu)
							(calc-prob-ram ?ram)
							(calc-prob-temp ?temp ?cpu)
							(calc-prob-reinicio ?rein ?ram ?temp)
						)
					)
					(bind ?sum_total (+ ?sum_total ?p_asig))
					(if (eq ?rein ?valor-objetivo)
						then (bind ?sum_objetivo (+ ?sum_objetivo ?p_asig))
					)
				)
			)
		)
	)
	
	;; Calcular probabilidad posterior
	(bind ?posterior (/ ?sum_objetivo ?sum_total))
	
	;; Imprimir resultado con el valor TRUE o FALSE del reinicio
	(printout t "La probabilidad de reinicio inesperado (" ?valor-objetivo ") dadas la evidencias observadas es: " (/ (round (* ?posterior 100000)) 100000) crlf)
)

;; Funcion para calcular la prob de Temperatura Alta dado sintomas
(deffunction calc-inf-temperatura-alta (?valor-objetivo)
	(bind ?sum_objetivo 0.0)
	(bind ?sum_total 0.0)
	
	;; Obtener los hechos de cada variable usando find-all-facts y nth$
	(bind ?cpu-fact  (nth$ 1 (find-all-facts ((?f estado)) (eq ?f:nombre CPU_Alta))))
	
	(bind ?cpu_state  (fact-slot-value ?cpu-fact valor))
	
	;; Generar las listas de valores según evidencia (o desconocido)
	(bind ?lista-cpu  (opciones ?cpu_state))
	
	;; Enumerar sobre todas las combinaciones:
	(foreach ?cpu ?lista-cpu
		(foreach ?temp (create$ TRUE FALSE)
			(bind ?p_asig 
				(* 	(calc-prob-cpu ?cpu)
					(calc-prob-temp ?temp ?cpu)
				)
			)
			(bind ?sum_total (+ ?sum_total ?p_asig))
			(if (eq ?temp ?valor-objetivo)
				then (bind ?sum_objetivo (+ ?sum_objetivo ?p_asig))
			)
		)
	)
  
	;; Calcular la probabilidad posterior
	(bind ?posterior (/ ?sum_objetivo ?sum_total))
  
	;; Imprimir el resultado
	(printout t "La probabilidad de temperatura alta (" ?valor-objetivo ") dadas la evidencias observadas es: " (/ (round (* ?posterior 100000)) 100000) crlf)
)



;; Funcion para calcular la prob de Sistema Operativo Inestable dado sintomas
(deffunction calc-inf-sist-inestable (?valor-objetivo)
	(bind ?sum_objetivo 0.0)
	(bind ?sum_total 0.0)
	
	;; Obtener los hechos de cada variable usando find-all-facts y nth$
	(bind ?cpu-fact  (nth$ 1 (find-all-facts ((?f estado)) (eq ?f:nombre CPU_Alta))))
	(bind ?disk-fact (nth$ 1 (find-all-facts ((?f estado)) (eq ?f:nombre Disco_Error))))
	
	(bind ?cpu_state  (fact-slot-value ?cpu-fact valor))
	(bind ?disk_state (fact-slot-value ?disk-fact valor))
	
	;; Generar las listas de valores según evidencia (o desconocido)
	(bind ?lista-cpu  (opciones ?cpu_state))
	(bind ?lista-disk (opciones ?disk_state))
	
	;; Enumerar sobre todas las combinaciones:
	(foreach ?cpu ?lista-cpu
		(foreach ?disk ?lista-disk
			(foreach ?so (create$ TRUE FALSE)
				(bind ?p_asig 
					(* 	(calc-prob-cpu ?cpu)
						(calc-prob-disco ?disk)
						(calc-prob-so ?so ?cpu ?disk)
					)
				)
			
				(bind ?sum_total (+ ?sum_total ?p_asig))
				(if (eq ?so ?valor-objetivo)
					then (bind ?sum_objetivo (+ ?sum_objetivo ?p_asig))
				)
			)
		)
	)
  
	;; Calcular la probabilidad posterior
	(bind ?posterior (/ ?sum_objetivo ?sum_total))
	
	;; Imprimir el resultado
	(printout t "La probabilidad de sistema operativo inestable (" ?valor-objetivo ") dadas la evidencias observadas es: " (/ (round (* ?posterior 100000)) 100000) crlf)
)

;; Función para calcular la probabilidad de CPU Alta
(deffunction calc-inf-nodo-CPU-Alta (?valor-objetivo)
	(bind ?sum_objetivo 0.0)
	(bind ?sum_total 0.0)
	
	;; Obtener el hecho del nodo
	(bind ?cpu-fact (nth$ 1 (find-all-facts ((?f estado)) (eq ?f:nombre CPU_Alta))))
	(bind ?cpu_state (fact-slot-value ?cpu-fact valor))
	
	;; Generar la lista de valores según evidencia (o desconocido)
	(bind ?lista-cpu (opciones ?cpu_state))
	
	;; Enumerar sobre todas las combinaciones:
	(foreach ?cpu ?lista-cpu
		(bind ?p_asig (calc-prob-cpu ?cpu))
		(bind ?sum_total (+ ?sum_total ?p_asig))
		(if (eq ?cpu ?valor-objetivo)
			then (bind ?sum_objetivo (+ ?sum_objetivo ?p_asig))
		)
	)
	
	;; Calcular la probabilidad posterior
	(bind ?posterior (/ ?sum_objetivo ?sum_total))
	
	;; Imprimir el resultado
	(printout t "La probabilidad de CPU Alta (" ?valor-objetivo ") dadas las evidencias observadas es: " (/ (round (* ?posterior 100000)) 100000) crlf)
)

;; Función para calcular la probabilidad de RAM Error
(deffunction calc-inf-nodo-RAM-Error (?valor-objetivo)
	(bind ?sum_objetivo 0.0)
	(bind ?sum_total 0.0)
	
	;; Obtener el hecho del nodo
	(bind ?ram-fact (nth$ 1 (find-all-facts ((?f estado)) (eq ?f:nombre RAM_Error))))
	(bind ?ram_state (fact-slot-value ?ram-fact valor))
	
	;; Generar la lista de valores según evidencia (o desconocido)
	(bind ?lista-ram (opciones ?ram_state))
	
	;; Enumerar sobre todas las combinaciones:
	(foreach ?ram ?lista-ram
		(bind ?p_asig (calc-prob-ram ?ram))
		(bind ?sum_total (+ ?sum_total ?p_asig))
		(if (eq ?ram ?valor-objetivo)
			then (bind ?sum_objetivo (+ ?sum_objetivo ?p_asig))
		)
	)
	
	;; Calcular la probabilidad posterior
	(bind ?posterior (/ ?sum_objetivo ?sum_total))
	
	;; Imprimir el resultado
	(printout t "La probabilidad de RAM Error (" ?valor-objetivo ") dadas las evidencias observadas es: " (/ (round (* ?posterior 100000)) 100000) crlf)
)

;; Función para calcular la probabilidad de Disco Error
(deffunction calc-inf-nodo-Disco-Error (?valor-objetivo)
	(bind ?sum_objetivo 0.0)
	(bind ?sum_total 0.0)
	
	;; Obtener el hecho del nodo
	(bind ?disco-fact (nth$ 1 (find-all-facts ((?f estado)) (eq ?f:nombre Disco_Error))))
	(bind ?disco_state (fact-slot-value ?disco-fact valor))
	
	;; Generar la lista de valores según evidencia (o desconocido)
	(bind ?lista-disco (opciones ?disco_state))
	
	;; Enumerar sobre todas las combinaciones:
	(foreach ?disco ?lista-disco
		(bind ?p_asig (calc-prob-disco ?disco))
		(bind ?sum_total (+ ?sum_total ?p_asig))
		(if (eq ?disco ?valor-objetivo)
			then (bind ?sum_objetivo (+ ?sum_objetivo ?p_asig))
		)
	)
	
	;; Calcular la probabilidad posterior
	(bind ?posterior (/ ?sum_objetivo ?sum_total))
	
	;; Imprimir el resultado
	(printout t "La probabilidad de Disco Error (" ?valor-objetivo ") dadas las evidencias observadas es: " (/ (round (* ?posterior 100000)) 100000) crlf)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;			          Regla para la Consulta
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule consulta-general
	?c <- (consulta (nombre ?nom) (valor ?v))
	=>
	(if (or (eq ?nom Caida_Servidor)
		(eq ?nom Reinicio) 
        (eq ?nom Temp_Alta) 
        (eq ?nom SO_Inestable)
		(eq ?nom CPU_Alta)
		(eq ?nom RAM_Error)
		(eq ?nom Disco_Error))
    then
		(if (eq ?nom Caida_Servidor)
			then (calc-inf-caida-servidor ?v))
		(if (eq ?nom Reinicio)
			then (calc-inf-reinicio ?v))
		(if (eq ?nom Temp_Alta)
			then (calc-inf-temperatura-alta ?v))
		(if (eq ?nom SO_Inestable)
			then (calc-inf-sist-inestable ?v))
		(if (eq ?nom CPU_Alta)
			then (calc-inf-nodo-CPU-Alta ?v))
		(if (eq ?nom RAM_Error)
            then (calc-inf-nodo-RAM-Error ?v))
		(if (eq ?nom Disco_Error)
            then (calc-inf-nodo-Disco-Error ?v))
  )
  (retract ?c)
)