import csv
import sys
import argparse

import pandas as pd
import nltk
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords

from gsdmm.mgp import MovieGroupProcess

def compute_V(docs):
    vocabs = set()
    for doc in docs:
        for word in doc:
            vocabs.add(word)
    return vocabs

def tokenize(text):
    return word_tokenize(text)

grammar = r"""
  MIN: {<DT>?<NNP><IN><DT>?<NNP>+(<,><NNP>+)*(<CC><NNP>+)?}
  ASK1: {^<NNP>+<VBD><MIN>(<CC><MIN>)?}
  MAYBEASK1: {^<NNP>+<VBD>}
  ASK2: {^<DT><JJ><NN><VBD><IN><DT><NN><IN><NNP>+}
  TOASK: {<TO><VB><MIN>}
"""

def question_tokens(text):
    text = text.replace("Prime Minister", "Minister of Prime")

    tokenized = tokenize(text)
    tagged = nltk.pos_tag(tokenized)

    cp = nltk.RegexpParser(grammar)

    tree = cp.parse(tagged)

    tokens = []

    detected = False
    for item in tree:
        if type(item) == tuple:
            tokens.append(item[0])
        if type(item) == nltk.tree.Tree:
            if item.label() == "MIN" and "Minister/NNP" not in str(item):
                tokens.extend([i[0] for i in item])
            elif item.label() == "MAYBEASK1" and "asked/VBD" not in str(item):
                tokens.extend([i[0] for i in item])
            else:
                detected = True

    return tokens

def remove_stop_words(tokens):
    stop_words = set(stopwords.words('english'))
    stop_words.update(["(", ")", ",", ".", "whether", "Ministry",
                "a", "b", "c", "d","Singapore", "Singaporean", "i", "ii", "iii", ";", "'s"])
    return [t for t in tokens if t not in stop_words]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Topic Modelling on Singapore PM questions")
    parser.add_argument("questions", type=str)
    parser.add_argument("clusters", type=int)
    #parser.add_argument("labels", type=str)

    args = parser.parse_args()

    clusters = args.clusters

    with open(args.questions) as questions:
        full_questions_dataset = csv.DictReader(questions)
        docs = []
        questions = []

        for line in full_questions_dataset:
            tokens = question_tokens(line['Question'])
            docs.append(tokens)
            questions.append(' '.join(remove_stop_words(tokens)))
            #print(questions)
    vocabs = compute_V(docs)
    #print(vocabs)
    mgp = MovieGroupProcess(K=clusters, n_iters=100, alpha=0.2, beta=0.01)
    y = mgp.fit(docs, len(vocabs))
    print(y)

    with open("output/" + '{}_clusters'.format(clusters) + '.csv', 'w') as output:
        fieldnames = ['labels']

        writer = csv.DictWriter(output, fieldnames=fieldnames)
        writer.writeheader()
        for label in y:
            writer.writerow({'labels': label})

    print("{} labels and {} questions altogether".format(len(y), len(questions)))
    questions_labels = {'Question': questions, 'label': y}
    results = pd.DataFrame(questions_labels)
    results.to_csv("./output/{}_clusters_with_questions.csv".format(clusters), index=False)
