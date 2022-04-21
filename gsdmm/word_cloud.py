import argparse

import pandas as pd
import matplotlib.pyplot as plt
from tqdm import tqdm
from wordcloud import WordCloud

def draw_wordcloud(wc, cluster):
    plt.figure(figsize=(10, 10))
    plt.imshow(wc) 
    plt.axis("off")
    plt.savefig("./output/figures/cluster_{}.png".format(cluster))

def create_wordcloud(text):
    word_cloud = WordCloud().generate(text)
    return word_cloud


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Draw word cloud")
    parser.add_argument("results", type=str)
    args = parser.parse_args()
    questions_labels = pd.read_csv(args.results)
    col_names = list(questions_labels.columns)
    clusters = questions_labels[col_names[1]].nunique()

    print(questions_labels.label.unique())
    print(questions_labels)

    for k in tqdm(range(clusters)):
        questions = questions_labels.loc[questions_labels[col_names[1]] == k, col_names[0]]
        questions_doc = ' '.join(questions)
        wc = create_wordcloud(questions_doc)
        draw_wordcloud(wc, k)
    
