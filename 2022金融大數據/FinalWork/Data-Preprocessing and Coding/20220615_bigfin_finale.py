# -*- coding: utf-8 -*-
"""
Created on Wed Jun 15 14:37:47 2022

@author1: 應統碩一 410336130 陳冠廷
@author2: 應統職二 408145137 駱俊宏
"""
#%%
import pandas as pd
import os
os.chdir("C:/Users/ChunhungLo/Documents/GitHub/finBigdata")
df = pd.read_excel('bigfin_dataset_刪除重複.xlsx')
#%%
# df.info() # data frame structure check
print(pd.concat([df["Title"].astype(str).map(len).describe(), df["Context"].astype(str).map(len).describe()], axis=1))
SnACrtb = pd.crosstab(index = df["Author"], columns= df["Source"],margins=True)
# print(df["Source"].describe())
# print(df["Author"].describe())
print(f'資料日期開始 {df["Time"].min()} ,結束 {df["Time"].max()}')
print(df["Time"].dt.to_period('M').value_counts())

#%%
import re
punctuation = """！？｡＂＃＄％＆＇（）＊＋－／：；＜＝＞＠［＼］＾＿｀｛｜｝～｟｠｢｣､、〃》「」『』【】〔〕〖〗〘〙〚〛〜〝〞〟〰〾〿–—‘'‛“”„‟…‧﹏"""
punctuation2 = "&#<>{}\[\]\\.%()。，"
re_punctuation = "[{}]|[{}]".format(punctuation, punctuation2) 

RE_SUSPICIOUS = re.compile(re_punctuation)
re_punctuation

def impurity(text, min_len=10):
    """returns the share of suspicious characters in a text"""
    if text == None or len(text) < min_len:
        return 0
    else:
        return len(RE_SUSPICIOUS.findall(text))/len(text)
df['Impurity']=df['Context'].apply(impurity, min_len=10)
df.columns
df_Impurity_ba = df[['Context', 'Impurity']].sort_values(by='Impurity', ascending=False).head(3)
#%%
def clean(text):
    # tags like <tab>
    text = re.sub(r'<[^<>]*>', ' ', text)
    # markdown URLs like [Some text](https://....)
    text = re.sub(r'\[([^\[\]]*)\]\([^\(\)]*\)', ' ', text)
    # text or code in brackets like [0]
    text = re.sub(r'\[[^\[\]]*\]', ' ', text)
    # standalone sequences of specials, matches &# but not #cool
    text = re.sub(r'(?:^|\s)[&#<>{}\[\]+|\\:-]{1,}(?:\s|$)', ' ', text)
    # standalone sequences of hyphens like --- or ==
    text = re.sub(r'(?:^|\s)[\-=\+]{2,}(?:\s|$)', ' ', text)
    # sequences of white spaces
    text = re.sub(r'\s+', ' ', text)
    # remove number
    text = re.sub(r'\d+', ' ', text)
    # remove 全形符號
    text = re.sub(re_punctuation, ' ', text)
    return text.strip()

df['Clean_text'] = df['Context'].apply(clean)
df['Impurity']   = df['Clean_text'].apply(impurity, min_len=10)

df_Impurity_af = df[['Clean_text', 'Impurity']].sort_values(by='Impurity', ascending=False) \
                              .head(3)    
#%%
###Part IV: Character Masking with textacy###                          
from textacy.preprocessing import replace
df['Clean_text'] = df['Clean_text'].apply(replace.urls)

df.rename(columns={'Context': 'Raw_text', 'Clean_text': 'Context'}, inplace=True)
df.drop(columns=['Impurity'], inplace=True)

#%%
##########################
###Liguistic Processing###
##########################
#1加入繁體詞典
import jieba, os
jieba.set_dictionary('dict.txt.big.txt')

stopwords1 = [line.strip() for line in open('stopWords.txt', 'r', encoding='utf-8').readlines()]

def remove_stop(text):
    c1=[]
    for w in text:
        if w not in stopwords1:
            c1.append(w)
    c2=[i for i in c1 if i.strip() != '']
    return c2

df['tokens']=df['Context'].apply(jieba.cut)
df['tokens_new']=df['tokens'].apply(remove_stop)
df.iloc[0,:]

#Freq charts
from collections import Counter
counter = Counter()#use a empty string first
df['tokens_new'].apply(counter.update)
print(counter.most_common(15))

import seaborn as sns
sns.set(font="SimSun")
min_freq=2
#transform dict into dataframe
freq_df = pd.DataFrame.from_dict(counter, orient='index', columns=['freq'])
freq_df = freq_df.query('freq >= @min_freq')
freq_df.index.name = 'token'
freq_df = freq_df.sort_values('freq', ascending=False)
freq_df.head(15)

ax = freq_df.head(15).plot(kind='barh', width=0.95, figsize=(8,3))
ax.invert_yaxis()
ax.set(xlabel='Frequency', ylabel='Token', title='Top Words')
#%%
###Creating Word Clouds
from matplotlib import pyplot as plt
from wordcloud import WordCloud ###
from collections import Counter ###

wordcloud = WordCloud(font_path="SimHei.ttf", background_color="white")
wordcloud.generate_from_frequencies(freq_df['freq'])
#plt.figure(figsize=(20,10)) 
plt.imshow(wordcloud)
#%%

# DocTermMatrix_詞組矩陣
def list_to_string(org_list, seperator=' '):
    return seperator.join(org_list)

df['News_seg']=df['tokens_new'].apply(list_to_string)
# df['News_seg'][1]
import collections
termcounter = collections.Counter()

from sklearn.feature_extraction.text import CountVectorizer

cv = CountVectorizer(decode_error='ignore', min_df=2) 
dt01c = cv.fit_transform(df['News_seg'])
print(cv.get_feature_names())
fnc=cv.get_feature_names()


dtmatrixc=pd.DataFrame(dt01c.toarray(), columns=fnc)
#%%
# 相似度分析
from sklearn.metrics.pairwise import cosine_similarity
sm = pd.DataFrame(cosine_similarity(dt01c, dt01c))

cosine_similarity(dt01c[7], dt01c[43]) #相似度 array([[0.5028108]])
cosine_similarity(dt01c[26], dt01c[39]) #相似度 array([[0.50139906]])
cosine_similarity(dt01c[14], dt01c[28]) #相似度 array([[0.48868814]])
cosine_similarity(dt01c[46], dt01c[23]) #相似度 array([[0.47533479]])
cosine_similarity(dt01c[35], dt01c[39]) #相似度 array([[0.46542206]])

## 相似度 50.28%
# print("原文", df['Raw_text'][7])
# print("原文", df['Raw_text'][43])
# ## 相似度 50.13%
# print("原文", df['Raw_text'][14])
# print("原文", df['Raw_text'][28])
# ## 相似度 48.86%
# print("原文", df['Raw_text'][26])
# print("原文", df['Raw_text'][39])
#%%
from sklearn.feature_extraction.text import TfidfTransformer
tfidf = TfidfTransformer()

tfidf_dt = tfidf.fit_transform(dt01c)
tfidfmatrix = pd.DataFrame(tfidf_dt.toarray(), columns=cv.get_feature_names())
sm1 =pd.DataFrame(cosine_similarity(tfidf_dt, tfidf_dt))
#相似度稍微降低，但仍是最高
cosine_similarity(tfidf_dt[7], tfidf_dt[43]) 

# print("原文", df['Raw_text'][7])
# print("原文", df['Raw_text'][43])
#%%
from matplotlib import pyplot as plt
from wordcloud import WordCloud ###
from collections import Counter ###

tfidfsum=tfidfmatrix.T.sum(axis=1)

wordcloud = WordCloud(font_path="SimHei.ttf", background_color="white")
wordcloud.generate_from_frequencies(tfidfsum)
#plt.figure(figsize=(20,10)) 
plt.imshow(wordcloud)
#%%
from sklearn.cluster import KMeans

from sklearn import preprocessing 
distortions = []
for i in range(1, 31):
    km = KMeans(
        n_clusters=i, init='random',
        n_init=10, max_iter=300,
        tol=1e-04, random_state=0
    )
    km.fit(preprocessing.normalize(tfidf_dt))
    distortions.append(km.inertia_)

# plot
from matplotlib import pyplot as plt
plt.plot(range(1, 31), distortions, marker='o')
plt.xlabel('Number of clusters')
plt.ylabel('Distortion')
plt.show()
#%%

km = KMeans(
    n_clusters=5, init='random',
    n_init=10, max_iter=300, 
    tol=1e-04, random_state=0
)
y_km = km.fit_predict(preprocessing.normalize(tfidf_dt))

g0 = df['Context'][y_km==0]
print(g0.head())
g1 = df['Context'][y_km==1]
print(g1.head())
# 比較沒有意義
g2 = df['Context'][y_km==2]
print(g2.head())
g3 = df['Context'][y_km==3]
print(g3.head())
g4 = df['Context'][y_km==4]
print(g4.head())
