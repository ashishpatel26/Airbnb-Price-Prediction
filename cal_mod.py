
# coding: utf-8

# In[64]:


import pandas as pd
import numpy as np
import math
data=pd.read_csv('calendar_detail.csv',nrows=200000)
df=pd.DataFrame(data)

d = pd.read_csv('calendar_detail.csv')
d1 = pd.DataFrame(d)
#df.to_csv('calendar_mod.csv')
print(d1['listing_id'].nunique())
print(df['listing_id'].nunique())


# In[65]:


ids=np.unique(df['listing_id'])
count=0
for i in df.values:
    if(pd.isna(i[3])):
        count+=1
    
    
print(count)
lis_ids=[]
nulist=[]
counts=[]
new=df.groupby('listing_id')
count1=0
for i,j in new:
    lis_ids.append(i)
    q=np.array(j['price'])
    nulist.append(len(q))
    
    for k in q:
        if(pd.isna(k)):
            
            count1+=1
    counts.append(count1)
    count1=0
for i in range(0,len(counts)):
    print(lis_ids[i],nulist[i],counts[i])
new_df=pd.DataFrame(list(zip(lis_ids,nulist,counts)))
removes=[]
for i in new_df.values:
    if(i[2]>=219):
        removes.append(i[0])
print(removes)
#removes_num = set(removes) 
#for ind,i in enumerate(df.values):
    #if(i[0] in removes_num):
        #df.drop(ind,inplace=True)
df = df[~df['listing_id'].isin(removes)]
print(len(df))
df=df[1:]


# In[66]:


# from datetime import datetime
# datetime_object = datetime.strptime('2018-09-23', '%Y-%m-%d')
# print(datetime_object, df['date'].iloc[1])
# #weekno = datetime.datetime.pd.to_datetime(df['date'].iloc[1], format='%Y%m%d', errors='ignore').weekday()
# print(datetime_object.weekday())


# In[67]:


day=[]
for i in range(len(df)):
  if(datetime.strptime(df['date'].iloc[i], '%Y-%m-%d').weekday()<5):
    b = 1
  else:
    b = 0
  
  day.append(b)

df['day']=day


# In[68]:


#to fill missing values

df.insert(0, 'r_id', range(0, 0 + len(df)))
df['price'] = df['price'].str.replace('$', '')
df['price'] = df['price'].str.replace(',', '')

df['price'] = pd.to_numeric(df['price'])

def prev5(d,listingId,rid,day):
    prev=d.loc[(d['listing_id'] == listingId) & (d['r_id']<rid) & (d.price.notnull()) & (d['day']==day)]
    return prev.tail(5)
    
def next5(d,listingId,rid,day):
    next=d.loc[(d['listing_id'] == listingId) & (d['r_id']>rid) & (d.price.notnull()) & (d['day']==day)]
    return next.head(5)


for i, row in df.iterrows():
      if pd.isnull(row['price']):
        print(row['price'], i)
        pre = prev5(df,row['listing_id'],row['r_id'],row['day'])
        if(len(pre.index)>4):
            df.at[i,'price'] = pre['price'].mean()
        else:
           nex = next5(df,row['listing_id'],row['r_id'],row['day'])
           if(len(nex.index)>4):
                df.at[i,'price'] = nex['price'].mean()
                
df = df.drop('r_id', axis=1)
df.to_csv('calendar_clean.csv',index=False)

