# -*- coding: utf-8 -*-
import pandas as pd
import numpy as np

import random

from deap import algorithms
from deap import base
from deap import creator
from deap import tools


data = pd.read_csv('https://raw.githubusercontent.com/nom-gv/SegundoParcialInteligenciaArtificial_REP/main/TercerEjercicio/Grafo.csv')

data.columns=["A","B","C","D","E"]
matriz = data[["A","B","C","D","E"]]
matriz = np.array(matriz)

print("-----MATRIZ DE DISTANCIAS-----")
print(matriz)

#CODIGO DEL AGENTE VIAJERO
distance_map = matriz
TB_SIZE = 5

#Implementacion del agente viajero en la matriz
def evalRutas(individual):
    distancia = distance_map[individual[-1]][individual[0]]
    for gene1, gene2 in zip(individual[0:-1], individual[1:]):
        distancia += distance_map[gene1][gene2]
    return distancia,

creator.create("FitnessMin", base.Fitness, weights=(-1.0,))
creator.create("Individual", list, fitness=creator.FitnessMin)

#Atributo generador
toolbox = base.Toolbox()
toolbox.register("indices", random.sample, range(TB_SIZE), TB_SIZE)

#Inicializando la estructura
toolbox.register("individual", tools.initIterate, creator.Individual, toolbox.indices)
toolbox.register("population", tools.initRepeat, list, toolbox.individual)

toolbox.register("evaluate", evalRutas)
toolbox.register("mate", tools.cxPartialyMatched)
toolbox.register("mutate", tools.mutShuffleIndexes, indpb=2.0/TB_SIZE)
toolbox.register("select", tools.selTournament, tournsize=30)

def main(seed=160):
    random.seed(seed)

    pop = toolbox.population(n=300)
    hof = tools.HallOfFame(1)
    stats = tools.Statistics(lambda ind: ind.fitness.values)
    stats.register("Avg", np.mean)
    stats.register("Std", np.std)
    stats.register("Min", np.min)
    stats.register("Max", np.max)

    algorithms.eaSimple(pop, toolbox, cxpb=0.7, mutpb=0.2, ngen=40, stats=stats,
                        halloffame=hof, verbose=False)

    
    return pop, stats, hof

if __name__ == "__main__":
    pop, stats, hof = main()
    print("----------Individuos mutados----------")
    print(pop)
    print("----------Mejor Recorrido----------")
    print(hof)
    print(evalRutas(hof[0]))