#!/usr/bin/env python
# coding: utf-8
# 建立資料夾與使用Pandas DataFrame
import os
import pandas as pd


# 檢查輸出入資料夾是否存在，輸出資料夾不存在則建立
sPath =os.getcwd() 
input_path = sPath + "\\data"
output_path=sPath + "\\SplitFiles"
print(f"來源資料夾: {input_path}\n輸出資料夾: {output_path}")
if not os.path.exists(input_path):
    print("來源資料夾不存在，請自行建立放入資料!! ")
if not os.path.exists(output_path):
    os.makedirs(output_path)
    print("已新增輸出資料夾!! ")
else:
    print("資料夾已存在!! ")

# 讀取來源資料檔案
FileName = input_path + "\\stockCSV.csv"  
stock = pd.read_csv(FileName, header=0, encoding='utf-8')

# 取得來源資料檔案中股票代號
stock_codes = set(stock['股票代碼'])

# 建立個別股票Df於dictionary結構中
# 透過日期內容字串處理, 完成輸出要求
stock_dicts = {}
i = 1
for stock_code in stock_codes:
    stock_dicts[stock_code] = stock[stock['股票代碼'] == stock_code]
    
for stock_code in stock_dicts:
    concatString=[]
    for YearMonth in sorted(set(stock_dicts[stock_code]['日期'].str[0:6])):
        n = int (stock_dicts[stock_code][stock_dicts[stock_code]["日期"] <=  (YearMonth +"/15")].shape[0])
        concatString.append(stock_dicts[stock_code][stock_dicts[stock_code]["日期"].str[0:6] <=  (YearMonth +"/15")].iloc[(n-5):n, ])
    one_stock = pd.concat(concatString)
    fileName=f"stock_{i:02}-{stock_code}.csv"
    one_stock.to_csv('SplitFiles\\'+fileName,encoding='utf_8_sig',index = False)
    i+=1
