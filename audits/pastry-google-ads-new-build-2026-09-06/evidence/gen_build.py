# Generates the Pastry Skincare Google Ads new-campaign build package from evidence.
import csv, json, os, re, sys, collections
S='/tmp/claude-0/-home-user-BeautyOnTapp/1fc7264b-40a1-5d35-b54a-f77b8153dbcb/scratchpad/pastry-google-build/'
OUT=S+'out/'; os.makedirs(OUT+'evidence',exist_ok=True)
EV='/home/user/BeautyOnTapp/audits/pastry-google-ads-2026-09-06/evidence/'
BASE='https://pastryskincare.co.za'

# ---------- evidence: feed (in-stock) ----------
feed=list(csv.DictReader(open(EV+'merchant_products_feed_copy.csv')))
# ---------- evidence: existing keywords with URLs + first-page bids ----------
kws=list(csv.DictReader(open(EV+'keywords_active_campaigns.csv')))
kwm={(r['ad_group'],r['keyword'],r['match_type']):r for r in csv.DictReader(open(EV+'keyword_metrics_active_2026-08-09_to_2026-09-05.csv'))}
url_by_group={}
fp={}
for r in kws:
    if 'Product' not in r['campaign']: continue
    u=json.loads(r['final_urls'])[0] if r['final_urls'].startswith('[') else r['final_urls']
    url_by_group[r['ad_group']]=u
    fp[(r['keyword'],r['match_type'])]=(int(r['first_page_cpc_micros'] or 0)/1e6,int(r['top_of_page_cpc_micros'] or 0)/1e6,r['quality_score'])
# Semrush
sem={}
for r in csv.DictReader(open(S+'semrush_za_demand_consolidated.csv')):
    k=r['Keyword'].strip().lower()
    try: v=int(r['Search Volume'])
    except: v=0
    if k not in sem or v>sem[k][0]: sem[k]=(v,r['CPC'],r['Keyword Difficulty Index'],r['seed_file'])
for r in csv.DictReader(open(EV+'semrush_za_keyword_demand.csv')):
    k=r['keyword'].strip().lower(); sem.setdefault(k,(int(r['za_monthly_volume']),r['cpc_usd'],r['keyword_difficulty'],'semrush_za_keyword_demand.csv'))

# ---------- products (in stock per feed copy 2026-09-06) ----------
P={
 'glycolic':dict(name='Glycolic Acid Body Wash',url=BASE+'/products/glycolic-acid-body-wash',price='R330',feed='shopify_ZZ_9322850550001_* (4 variants IN_STOCK, R330-R340)'),
 'salicylic':dict(name='Salicylic Acid Body Wash',url=BASE+'/products/salicylic-acid-body-wash',price='R330',feed='shopify_ZZ_8772643487985_* (6 variants IN_STOCK, R330-R340)'),
 'lactic':dict(name='Lactic Acid Body Wash',url=BASE+'/products/lactic-acid-body-wash',price='R310',feed='shopify_ZZ_8772640964849_* (2 variants IN_STOCK, R310)'),
 'mandelic':dict(name='Mandelic Acid Body Wash',url=BASE+'/products/mandelic-acid-body-wash',price='R545',feed='shopify_ZZ_9598972199153_48196957405425 Fragrance Free IN_STOCK R545; Blackcurrant variant OUT_OF_STOCK'),
 'niac_lotion':dict(name='Niacinamide Body Lotion',url=BASE+'/products/niacinamide-body-lotion',price='R325',feed='shopify_ZZ_8772641751281_* (2 variants IN_STOCK, R325-R335)'),
 'niac_butter':dict(name='Niacinamide Body Butter',url=BASE+'/products/niacinamide-body-butter',price='R205',feed='shopify_ZZ_8772641226993_* (2 variants IN_STOCK, R205-R210)'),
 'ha_lotion':dict(name='Hyaluronic Acid Body Lotion',url=BASE+'/products/hyaluronic-acid-body-lotion',price='R290',feed='shopify_ZZ_8772640178417_46009743147249 Fragrance Free IN_STOCK R290; Vanilla OUT_OF_STOCK'),
 'vitc_cream':dict(name='Vitamin C Body Cream',url=BASE+'/products/vitamin-c-body-cream',price='R285',feed='shopify_ZZ_8825020055793_* (2 variants IN_STOCK, R285-R295)'),
 'body_oil':dict(name='Brightening Body Oil',url=BASE+'/products/brightening-body-oil-vitamin-c',price='R385',feed='shopify_ZZ_9322841997553_46993404330225 IN_STOCK R385 (image_unwanted_overlays affects Shopping only)'),
 'bha_balm':dict(name='BHA Overnight Body Balm',url=BASE+'/products/bha-overnight-body-balm',price='R385',feed='shopify_ZZ_8825004228849_* (2 variants IN_STOCK, R385)'),
 'bha_gel':dict(name='BHA Body Gel Serum',url=BASE+'/products/bha-body-gel',price='R210',feed='shopify_ZZ_8772638114033_46213001543921 IN_STOCK R210'),
 'deo':dict(name='Anti Pigmentation Deodorant',url=BASE+'/products/anti-pigmentation-deodorant-linen-fresh-fragrance',price='R250',feed='shopify_ZZ_8772636180721_* (2 variants IN_STOCK, R250)'),
 'spf':dict(name='Niacinamide SPF50 Sunscreen',url=BASE+'/products/niacinamide-spf50-sunscreen',price='R465',feed='shopify_ZZ_8772642341105_46213088379121 IN_STOCK R465'),
 'pig_serum':dict(name='Pigmentation Correction Serum',url=BASE+'/products/pigmentation-correction-serum',price='R250',feed='shopify_ZZ_8767331172593_46213015339249 IN_STOCK R250 (5% niacinamide face serum)'),
 'epc':dict(name='Evening Pigment Corrector',url=BASE+'/products/evening-pigment-corrector',price='R295',feed='shopify_ZZ_9404701049073_47560294858993 IN_STOCK R295'),
 'ceramide':dict(name='Barrier Repair Serum',url=BASE+'/products/barrier-repair-serum-ceramide',price='R280',feed='shopify_ZZ_8767331467505_46213040406769 IN_STOCK R280'),
 'gly_kit':dict(name='Glycolic Acid & Niacinamide Mini Kit',url=BASE+'/products/pastry-skincare-glycolic-acid-niacinamide-mini-kit',price='R380',feed='shopify_ZZ_9319252820209_* (2 variants IN_STOCK, R380-R385)'),
 'sal_kit':dict(name='Salicylic Acid & Niacinamide Mini Kit',url=BASE+'/products/salicylic-acid-niacinamide-kit',price='R380',feed='shopify_ZZ_9319891960049_* (2 variants IN_STOCK, R380-R385)'),
 'gly_bundle':dict(name='Glycolic Acid Niacinamide Body Bundle',url=BASE+'/products/glycolic-acid-niacinamide-bundle',price='R655',feed='shopify_ZZ_9470478778609_* (2 variants IN_STOCK, R655-R670)'),
 'hyper_coll':dict(name='Hyperpigmentation collection',url=BASE+'/collections/hyperpigmentation',price='',feed='collection page used as final URL by paused campaign Search-brightening (ad 798619932669, APPROVED); live status NOT VERIFIED'),
}
# URL source check: every product URL must appear in existing keyword final URLs or existing ads
known_urls=set(url_by_group.values())
ads=json.load(open(EV+'ads_all_campaigns.json'))
for a in ads:
    for u in a.get('final_urls') or []: known_urls.add(u)
for k,p in P.items():
    p['url_source']='verified in account (existing keyword/ad final URL)' if p['url'] in known_urls else 'NOT IN SOURCE'
    assert p['url'] in known_urls, ('URL not in account evidence',k,p['url'])

# ---------- campaigns ----------
COMMON=dict(type='Search',networks='Google Search only (no search partners, no Display)',location='South Africa (presence only); exclude China, Hong Kong, Singapore (mirror of Pastry_Brand_Search)',language='English',goal='Pastry Skincare (web) purchase 7514901304 only (campaign-level goal, PURCHASE biddable) - same as Pastry_Brand_Search',bidding='Manual CPC (no enhanced CPC), keyword-level bids below; switch rule in runbook',rotation='Optimise (RSA)',suffix='utm_source=google&utm_medium=cpc&utm_campaign={campaignid}&utm_term={keyword}&utm_content={creative}')
C={
 'C1':dict(name='Pastry | Search | Body Wash | ZA | 2026-09',budget=150,**COMMON),
 'C2':dict(name='Pastry | Search | Body Lotion & Treatment | ZA | 2026-09',budget=120,**COMMON),
 'C3':dict(name='Pastry | Search | Concern Intent | ZA | 2026-09',budget=120,**COMMON),
 'C4':dict(name='Pastry | Search | Face Serums | ZA | 2026-09',budget=80,**COMMON),
}
C5=dict(name='Pastry | Shopping | All In-Stock | ZA | 2026-09',budget=150,type='Standard Shopping',networks='Google Search (Shopping)',location='South Africa (presence only)',language='n/a',goal='Pastry Skincare (web) purchase 7514901304',bidding='Manual CPC by product group (below); tROAS only after 30 purchases',rotation='n/a',suffix=COMMON['suffix'])

def S_(k):
    v=sem.get(k.lower()); return f"Semrush ZA {v[0]}/mo, CPC ${v[1]}, KD {v[2]}" if v else 'no Semrush ZA row'
def FP(k,mt):
    v=fp.get((k,mt)); return f"first-page est R{v[0]:.2f}, top R{v[1]:.2f}, QS {v[2] or '-'}" if v else 'no live bid estimate (keyword not in account)'
def LIVE(g,k,mt):
    m=kwm.get((g,k,mt)); 
    if not m: return 'no 28d serving history'
    return f"28d: {m['impressions']} impr, {m['clicks']} clicks, R{float(m['cost_zar'] or 0):.2f}, {m['conversions']} GA4 purchases R{float(m['conversions_value'] or 0):.2f}"

# ad groups: (campaign, group name, product key, [(keyword, match, bid, rationale_extra)])
AG=[
 ('C1','Glycolic Acid Body Wash','glycolic',[
   ('glycolic acid body wash','EXACT',4.50,'proven: 1 purchase 28d + Shopping purchases; bid to first-page est'),
   ('glycolic acid body wash','PHRASE',4.50,'catches long-tail; brand negatives keep pastry queries out'),
   ('glycolic body wash','EXACT',4.50,''),
   ('glycolic acid body cleanser','EXACT',4.00,'phrase variant produced 1 purchase R1,202 in 28d'),
   ('glycolic acid shower gel','EXACT',4.00,''),
   ('aha body wash','EXACT',3.50,'test; no ZA volume row'),
 ]),
 ('C1','Salicylic Acid Body Wash','salicylic',[
   ('salicylic acid body wash','EXACT',5.00,'highest-volume product term; 0 purchases in 28d at R3 bid with 26% IS, so step to R5.00 not the R6.47 estimate; stop rule applies'),
   ('salicylic acid body wash','PHRASE',4.50,''),
   ('salicylic body wash','EXACT',4.50,''),
   ('body acne wash','EXACT',4.00,'Shopping history: body acne wash clicks'),
   ('acne body wash','EXACT',4.00,''),
   ('body wash for body acne','EXACT',3.50,''),
   ('back acne body wash','EXACT',3.50,''),
   ('salicylic acid shower gel','EXACT',3.50,''),
 ]),
 ('C1','Lactic Acid Body Wash','lactic',[
   ('lactic acid body wash','EXACT',4.00,'phrase variant produced 1 purchase R1,270 in 28d'),
   ('lactic acid body wash','PHRASE',4.00,''),
   ('body wash for sensitive skin','EXACT',3.00,'test: product copy already positions lactic as gentle/sensitive'),
   ('body wash for keratosis pilaris','EXACT',3.00,'test'),
 ]),
 ('C1','Mandelic Acid Body Wash','mandelic',[
   ('mandelic acid body wash','EXACT',3.00,'40 clicks 0 purchases 28d; only R545 fragrance-free variant in stock; low bid + stop rule'),
   ('mandelic acid body wash','PHRASE',3.00,''),
 ]),
 ('C1','Brightening Body Wash (concern)','glycolic',[
   ('body wash for hyperpigmentation','EXACT',4.00,''),
   ('brightening body wash','EXACT',4.00,'seen as brand-campaign query'),
   ('body wash for dark marks','EXACT',3.50,''),
   ('body wash for dark inner thighs','EXACT',3.50,'Shopping term "how to remove dark inner thighs" produced a purchase'),
   ('exfoliating body wash','EXACT',3.50,'Shopping history: 9 clicks'),
   ('body wash for strawberry legs','EXACT',3.50,'existing description copy mentions strawberry skin'),
 ]),
 ('C2','Niacinamide Body Lotion','niac_lotion',[
   ('niacinamide body lotion','EXACT',6.50,'phrase variant: 4 purchases R2,785 in 28d at 18% IS; exact IS 24%; bid to first-page est'),
   ('niacinamide body lotion','PHRASE',6.50,''),
   ('niacinamide lotion','EXACT',5.00,'Shopping purchase history'),
   ('niacinamide body moisturiser','EXACT',4.00,'test'),
 ]),
 ('C2','Brightening Body Lotion (concern)','niac_lotion',[
   ('brightening body lotion','EXACT',4.50,''),
   ('skin brightening body lotion','EXACT',4.50,''),
   ('body lotion for hyperpigmentation','EXACT',5.00,''),
   ('body lotion for glowing skin','EXACT',4.00,''),
   ('body lotion for dark spots','EXACT',4.00,'test; no ZA row'),
   ('even tone body lotion','EXACT',3.50,'test'),
 ]),
 ('C2','Vitamin C Body Cream','vitc_cream',[
   ('vitamin c body cream','EXACT',4.50,'QS 4 in current build (ad relevance); new dedicated RSA should lift it'),
   ('vitamin c body lotion','EXACT',4.50,''),
   ('vitamin c body cream','PHRASE',4.00,''),
 ]),
 ('C2','Niacinamide Body Butter','niac_butter',[
   ('niacinamide body butter','EXACT',3.00,'QS 10, first-page est R0.99; Shopping purchase history'),
   ('body butter for dark marks','EXACT',3.00,'test'),
 ]),
 ('C2','Hyaluronic Acid Body Lotion','ha_lotion',[
   ('hyaluronic acid body lotion','EXACT',5.00,'first-page est R9.09; test at R5 with stop rule'),
   ('body lotion for dry skin','EXACT',3.50,''),
 ]),
 ('C2','Overnight Body Treatment (BHA)','bha_balm',[
   ('bha overnight body balm','EXACT',3.00,'first-page est R1.39'),
   ('overnight body balm','EXACT',3.00,''),
   ('bha body balm','EXACT',3.00,''),
 ]),
 ('C2','BHA Body Gel Serum','bha_gel',[
   ('bha body gel','EXACT',3.00,'QS 10'),
   ('bha body serum','EXACT',3.00,''),
   ('salicylic acid body serum','EXACT',3.50,''),
 ]),
 ('C2','Brightening Body Oil','body_oil',[
   ('brightening body oil','EXACT',3.50,''),
   ('vitamin c body oil','EXACT',3.00,''),
   ('body oil for dark marks','EXACT',3.00,'test'),
 ]),
 ('C3','Dark Underarms (deodorant)','deo',[
   ('anti pigmentation deodorant','EXACT',5.00,'first-page est R9.09, QS 8; step to R5.00'),
   ('deodorant for dark underarms','EXACT',5.00,''),
   ('deodorant for dark underarms','PHRASE',4.50,''),
   ('best deodorant for dark underarms','EXACT',5.00,''),
   ('best roll on for dark underarms','EXACT',5.00,''),
   ('roll on for dark underarms','EXACT',4.50,'seen as query in current build'),
   ('dark underarms treatment','EXACT',4.50,''),
   ('what to use for dark underarms','EXACT',4.00,''),
   ('dark underarms','EXACT',4.00,'head term 260/mo; monitor CTR'),
   ('underarm dark spots','EXACT',4.00,''),
   ('brightening deodorant','EXACT',4.00,'seen as query in current build'),
 ]),
 ('C3','Hyperpigmentation Body Care (concern)','hyper_coll',[
   ('hyperpigmentation products','EXACT',4.50,''),
   ('hyperpigmentation cream','EXACT',4.50,''),
   ('best products for hyperpigmentation','EXACT',4.50,''),
   ('hyperpigmentation treatment for dark skin','EXACT',4.00,'keyword only; ad copy avoids treatment claims'),
   ('hyperpigmentation treatment for body','EXACT',4.00,'Shopping purchase history (experiment campaign)'),
   ('products for hyperpigmentation black skin','EXACT',3.50,''),
   ('dark inner thighs','PHRASE',3.50,'Shopping purchase history'),
   ('dark knees and elbows','PHRASE',3.50,'test'),
   ('body care for hyperpigmentation','EXACT',4.00,''),
 ]),
 ('C4','Niacinamide Serum','pig_serum',[
   ('niacinamide serum','EXACT',4.00,'6,600/mo, KD 16; product is 5% niacinamide face serum R250; start below CPC benchmark and read CVR'),
   ('niacinamide serum','PHRASE',3.50,''),
   ('pigmentation correction serum','EXACT',4.00,''),
   ('hyperpigmentation serum','EXACT',5.00,''),
   ('best serum for hyperpigmentation','EXACT',5.00,''),
   ('serum for dark marks','EXACT',4.00,'test'),
 ]),
 ('C4','Dark Spot Corrector','epc',[
   ('dark spot corrector','EXACT',4.50,'1,600/mo'),
   ('dark spot corrector','PHRASE',4.00,''),
   ('evening pigment corrector','EXACT',3.00,''),
   ('dark mark corrector','EXACT',3.50,'test'),
 ]),
 ('C4','Ceramide Serum','ceramide',[
   ('ceramide serum','EXACT',4.00,'320/mo, KD 8'),
   ('barrier repair serum','EXACT',4.00,''),
   ('skin barrier serum','EXACT',3.50,'test'),
 ]),
 ('C4','Niacinamide Sunscreen','spf',[
   ('niacinamide sunscreen','EXACT',4.00,''),
   ('niacinamide spf50 sunscreen','EXACT',3.00,''),
   ('spf50 gel sunscreen','EXACT',3.00,'test'),
 ]),
]

# ---------- RSA copy ----------
HL_COMMON=['Pastry Skincare Official Store','Proudly South African Brand','Made For Melanin-Rich Skin','Fragrance-Free Options','Shop Online Today']
DS_COMMON_TRUST='Body care made in South Africa for melanin-rich skin. Fragrance-free options available.'
from rsa_copy import RSA

BANNED=re.compile(r'\b(free delivery|free shipping|shipping|delivery|deliver|pickup|pick-up|courier|cure|cures|treat|treats|treatment|bleach|whiten|whitening|lighten|lightening|dermatologist|clinically|guarantee|#1|no\.1|best)\b',re.I)

# ---------- negatives ----------
NEG_BRAND=['pastry','pastry skincare','pastryskincare','pasty skincare','pantry skincare','pastry skin']
NEG_COMP=['dove','nivea','sanex','lux','radox','dettol','sorbet','epimax','satiskin','lifebuoy','oh so heavenly','palmers','cerave','the ordinary','standard beauty','medicube','aplb','neutrogena','eucerin','la roche posay','bio oil','vaseline','clere','portia m','good stuff','dr teals','olay','aveeno','shower to shower','kiehls','loccitane','minimalist','veerox','avon','justine']
NEG_RETAIL=['dischem','dis-chem','clicks','woolworths','takealot','shoprite','checkers','pick n pay','amazon','superbalist','faithful to nature']
NEG_INFO=['recipe','recipes','cake','cakes','bakery','baking','pie','croissant','how to make','diy','homemade','home remedies','meaning','causes','what is','side effects','laser','chemical peel','dermatologist','doctor','clinic','wholesale','bulk','supplier','distributor','private label','job','jobs','vacancies','salary','course','free','cheap','review','reviews','vs','before and after','pregnancy','boy or girl','penis','men','mens','baby','kids','child']
NEG_POSITION=['whitening','lightening','bleach','bleaching','skin lightening','hand cream','hand lotion']
NEG_FACE_IN_BODY=['face','facial','face serum','face wash','face cream','eye','lip','lips']
NEG_BODY_IN_FACE=['body','body wash','body lotion','underarm','underarms','inner thigh','inner thighs','knees','elbows']

def out_csv(name,rows,fields):
    with open(OUT+name,'w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=fields); w.writeheader(); w.writerows(rows)

# 01 campaign plan
rows=[]
for cid,c in list(C.items())+[('C5',C5)]:
    rows.append(dict(build_id=cid,campaign_name=c['name'],campaign_type=c['type'],status_on_import='PAUSED (enable in launch step 6)',daily_budget_zar=c['budget'],bidding=c['bidding'],networks=c['networks'],locations=c['location'],language=c['language'],conversion_goal=c['goal'],ad_rotation=c['rotation'],final_url_suffix=c['suffix'],
        evidence='Account: geo/language/network settings mirror Pastry_Brand_Search 23660059123 (campaigns_inventory.csv); goal set mirrors campaign-level PURCHASE~WEBSITE config; auto-tagging enabled (customer query 2026-09-06)'))
out_csv('01_campaign_plan.csv',rows,list(rows[0].keys()))

# 02 keywords
krows=[];seen=collections.Counter()
for cid,g,pk,klist in AG:
    p=P[pk]
    for k,mt,bid,why in klist:
        seen[(k,mt)]+=1
        krows.append(dict(build_id=cid,campaign=C[cid]['name'],ad_group=g,keyword=k,match_type=mt,max_cpc_zar=f"{bid:.2f}",final_url=p['url'],product=p['name'],feed_price_zar=p['price'],feed_evidence=p['feed'],
            demand_evidence=S_(k),live_bid_evidence=FP(k,mt),serving_evidence=LIVE(next((gg for gg,u in url_by_group.items() if u==p['url']),''),k,mt),rationale=why,url_source=p['url_source'],live_page_check='NOT VERIFIED (egress blocked in session)'))
dups=[k for k,v in seen.items() if v>1]; assert not dups,dups
out_csv('02_ad_groups_keywords.csv',krows,list(krows[0].keys()))

# 03 negatives
nrows=[]
def addneg(scope,lst,name,mt,why):
    for t in lst: nrows.append(dict(scope=scope,list_or_campaign=name,keyword=t,match_type=mt,rationale=why))
addneg('shared list (apply to C1-C4, NOT to Pastry_Brand_Search, NOT to C5 Shopping)',NEG_BRAND,'Pastry | NEG | Brand routing','PHRASE','Route brand queries to Pastry_Brand_Search; in the current product campaign 20 of 60 top queries were "pastry ..." (search_terms_active_campaigns 28d)')
addneg('shared list (apply to C1-C5)',NEG_COMP,'Pastry | NEG | Competitor brands','PHRASE','Competitor brand queries seen in Shopping/Search terms (dove, nivea, standard beauty, the ordinary, medicube, aplb, palmers, neutrogena, kiehls, loccitane, minimalist) and Semrush body wash/lotion lists')
addneg('shared list (apply to C1-C5)',NEG_RETAIL,'Pastry | NEG | Retailers','PHRASE','Retailer-intent queries (dischem, clicks, woolworths) in Semrush lists; note Pastry_Brand_Search keeps them (it converted on "pastry skincare clicks")')
addneg('shared list (apply to C1-C4)',NEG_INFO,'Pastry | NEG | Informational and off-target','PHRASE','Pastry as a food word (recipe/cake/bakery), informational modifiers (meaning/causes/how to make), clinical/procedure intent, B2B, jobs, comparison; "men"/"kids"/"pregnancy" excluded because copy and pages are not positioned for them')
addneg('shared list (apply to C1-C5)',NEG_POSITION,'Pastry | NEG | Positioning and stock','PHRASE','Brand copy says "No bleaching"; whitening/lightening queries conflict with positioning and policy risk. Hand cream negated while Anti-Pigment Hand Cream SPF30 is OUT_OF_STOCK in the feed (2026-09-06)')
addneg('campaign C1, C2, C3',NEG_FACE_IN_BODY,'campaign-level','PHRASE','Keep face intent in C4')
addneg('campaign C4',NEG_BODY_IN_FACE,'campaign-level','PHRASE','Keep body intent in C1-C3')
addneg('campaign C3 ad group Dark Underarms',['how to get rid of','how to remove','how to lighten','baking soda','colgate','coconut oil','aloe vera'],'ad-group-level','PHRASE','Semrush dark-underarms list: home-remedy and how-to queries (KD 22-34) are informational')
out_csv('03_negative_keywords.csv',nrows,list(nrows[0].keys()))

# 04 RSA ads with validation
arows=[];viol=[]
for cid,g,pk,klist in AG:
    r=RSA[g]; p=P[pk]
    hs=r['h']+HL_COMMON; hs=list(dict.fromkeys(hs))[:15]
    ds=r['d'][:4]
    for h in hs:
        if len(h)>30: viol.append(('H>30',g,h,len(h)))
        if BANNED.search(h): viol.append(('banned',g,h))
    for d in ds:
        if len(d)>90: viol.append(('D>90',g,d,len(d)))
        if BANNED.search(d): viol.append(('banned',g,d))
    for pp in r['p']:
        if len(pp)>15: viol.append(('P>15',g,pp))
    row=dict(build_id=cid,campaign=C[cid]['name'],ad_group=g,ad_type='Responsive search ad',final_url=p['url'],path1=r['p'][0],path2=r['p'][1])
    for i,h in enumerate(hs,1): row[f'headline_{i}']=h
    for i in range(len(hs)+1,16): row[f'headline_{i}']=''
    for i,d in enumerate(ds,1): row[f'description_{i}']=d
    row['pinning']='none (let RSA optimise; review asset labels after 14 days)'
    row['claims_basis']='Ingredient and size facts from feed titles and existing approved ad copy (ads_all_campaigns.json); prices from feed copy 2026-09-06 (live page price NOT VERIFIED); no delivery, clinical or comparative claims'
    arows.append(row)
assert not viol, viol
out_csv('04_rsa_ads.csv',arows,list(arows[0].keys()))

# 05 assets
assets=[
 dict(asset_type='Sitelink',text='Glycolic Acid Body Wash',line1='SLS-free exfoliating wash',line2='From R330, 500ml',final_url=P['glycolic']['url'],apply_to='C1-C4 (campaign level)'),
 dict(asset_type='Sitelink',text='Niacinamide Body Lotion',line1='Niacinamide and panthenol',line2='From R325, 500ml',final_url=P['niac_lotion']['url'],apply_to='C1-C4'),
 dict(asset_type='Sitelink',text='Glycolic Mini Kit',line1='Body wash + lotion + loofah',line2='From R380',final_url=P['gly_kit']['url'],apply_to='C1-C4'),
 dict(asset_type='Sitelink',text='Salicylic Acid Body Wash',line1='For body acne and bumps',line2='From R330, 500ml',final_url=P['salicylic']['url'],apply_to='C1-C4'),
 dict(asset_type='Sitelink',text='Niacinamide Serum',line1='5% niacinamide face serum',line2='R250, 30ml',final_url=P['pig_serum']['url'],apply_to='C4 only'),
 dict(asset_type='Callout',text='SLS-Free Formulas',line1='',line2='',final_url='',apply_to='C1-C4'),
 dict(asset_type='Callout',text='Fragrance-Free Options',line1='',line2='',final_url='',apply_to='C1-C4'),
 dict(asset_type='Callout',text='Made In South Africa',line1='',line2='',final_url='',apply_to='C1-C4'),
 dict(asset_type='Callout',text='For Melanin-Rich Skin',line1='',line2='',final_url='',apply_to='C1-C4'),
 dict(asset_type='Structured snippet',text='Types: Body Wash, Body Lotion, Body Butter, Body Oil, Face Serum, Deodorant, Sunscreen',line1='',line2='',final_url='',apply_to='C1-C4'),
]
for a in assets:
    if a['asset_type']=='Sitelink': assert len(a['text'])<=25 and len(a['line1'])<=35 and len(a['line2'])<=35,a
    if a['asset_type']=='Callout': assert len(a['text'])<=25,a
    assert not BANNED.search(a['text']+a['line1']+a['line2']),a
out_csv('05_assets_sitelinks_callouts_snippets.csv',assets,list(assets[0].keys()))

# 06 Google Ads Editor import (Search campaigns)
ecols=['Campaign','Campaign Type','Campaign Status','Networks','Budget','Budget type','Bid Strategy Type','Languages','Location','Ad Group','Ad Group Status','Max CPC','Keyword','Criterion Type','Final URL','Final URL suffix','Ad type','Status','Path 1','Path 2']+[f'Headline {i}' for i in range(1,16)]+[f'Description {i}' for i in range(1,5)]
erows=[]
def E(**kw):
    r={c:'' for c in ecols}; r.update(kw); erows.append(r)
for cid,c in C.items():
    E(**{'Campaign':c['name'],'Campaign Type':'Search','Campaign Status':'Paused','Networks':'Google search','Budget':c['budget'],'Budget type':'Daily','Bid Strategy Type':'Manual CPC','Languages':'en','Location':'South Africa','Final URL suffix':c['suffix']})
    for loc in ['China','Hong Kong','Singapore']:
        E(**{'Campaign':c['name'],'Location':loc,'Criterion Type':'Negative Location'}) if False else None
for cid,g,pk,klist in AG:
    E(**{'Campaign':C[cid]['name'],'Ad Group':g,'Ad Group Status':'Enabled','Max CPC':'3.00'})
    for k,mt,bid,why in klist:
        E(**{'Campaign':C[cid]['name'],'Ad Group':g,'Keyword':k,'Criterion Type':mt.capitalize(),'Max CPC':f"{bid:.2f}",'Final URL':P[pk]['url'],'Status':'Enabled'})
    r=RSA[g]; hs=list(dict.fromkeys(r['h']+HL_COMMON))[:15]
    row={'Campaign':C[cid]['name'],'Ad Group':g,'Ad type':'Responsive search ad','Status':'Enabled','Final URL':P[pk]['url'],'Path 1':r['p'][0],'Path 2':r['p'][1]}
    for i,h in enumerate(hs,1): row[f'Headline {i}']=h
    for i,d in enumerate(r['d'][:4],1): row[f'Description {i}']=d
    E(**row)
# campaign-level negatives
for cid in ['C1','C2','C3']:
    for t in NEG_FACE_IN_BODY: E(**{'Campaign':C[cid]['name'],'Keyword':t,'Criterion Type':'Negative Phrase'})
for t in NEG_BODY_IN_FACE: E(**{'Campaign':C['C4']['name'],'Keyword':t,'Criterion Type':'Negative Phrase'})
for t in ['how to get rid of','how to remove','how to lighten','baking soda','colgate','coconut oil','aloe vera']:
    E(**{'Campaign':C['C3']['name'],'Ad Group':'Dark Underarms (deodorant)','Keyword':t,'Criterion Type':'Negative Phrase'})
with open(OUT+'06_google_ads_editor_import_search.csv','w',newline='') as f:
    w=csv.DictWriter(f,fieldnames=ecols); w.writeheader(); w.writerows(erows)
# shared negative lists import
lrows=[]
for name,lst in [('Pastry | NEG | Brand routing',NEG_BRAND),('Pastry | NEG | Competitor brands',NEG_COMP),('Pastry | NEG | Retailers',NEG_RETAIL),('Pastry | NEG | Informational and off-target',NEG_INFO),('Pastry | NEG | Positioning and stock',NEG_POSITION)]:
    for t in lst: lrows.append({'Shared list name':name,'Keyword':t,'Criterion Type':'Negative Phrase'})
out_csv('06b_google_ads_editor_import_negative_lists.csv',lrows,['Shared list name','Keyword','Criterion Type'])

# 07 shopping product groups
pg=[]
types=collections.Counter(); prices=collections.defaultdict(list)
for r in feed:
    if r['availability']=='IN_STOCK': types[r['product_type']]+=1; prices[r['product_type']].append(float(r['price_zar']))
bids={'body wash':3.00,'body lotion':3.00,'gift set':2.50,'body butter':2.00,'body cream':2.50,'body oil':2.00,'body balm':2.00,'body serum':2.00,'body mist':1.50,'deodorant':2.50,'face serum':2.00,'serum':2.00,'sunscreen':1.50,'hand cream':1.50}
for t,n in sorted(types.items(),key=lambda x:-x[1]):
    pg.append(dict(product_group=f'product_type = "{t}"',in_stock_items=n,price_range_zar=f"{min(prices[t]):.0f}-{max(prices[t]):.0f}",max_cpc_zar=f"{bids.get(t,2.00):.2f}",note='hand cream: only Hyaluronic Acid Hand Cream grapefruit is in stock; Anti-Pigment Hand Cream SPF30 is OUT_OF_STOCK and excluded automatically' if t=='hand cream' else ''))
pg.append(dict(product_group='Everything else',in_stock_items=0,price_range_zar='',max_cpc_zar='EXCLUDED',note='exclude so new feed items are reviewed before serving'))
out_csv('07_shopping_product_groups.csv',pg,list(pg[0].keys()))

# evidence copies
import shutil
shutil.copy(S+'semrush_za_demand_consolidated.csv',OUT+'evidence/semrush_za_demand_consolidated.csv')
shutil.copy(S+'asset_perf_L28.csv',OUT+'evidence/rsa_asset_performance_active_campaigns_2026-08-09_to_2026-09-05.csv')
json.dump({k:{**v} for k,v in P.items()},open(OUT+'evidence/product_destination_map.json','w'),indent=1)
# baseline
m=list(csv.DictReader(open(EV+'keyword_metrics_active_2026-08-09_to_2026-09-05.csv')))
t=collections.Counter()
for r in m:
    if 'Product' in r['campaign']:
        t['cost']+=float(r['cost_zar'] or 0); t['clicks']+=int(r['clicks'] or 0); t['conv']+=float(r['conversions'] or 0); t['val']+=float(r['conversions_value'] or 0); t['imp']+=int(r['impressions'] or 0)
json.dump({'campaign':'Pastry | Search | Product High Intent | 2026-08-14 (24142894204)','period':'2026-08-09..2026-09-05 (keyword-level sums)',**{k:round(v,2) for k,v in t.items()},'cpa_zar':round(t['cost']/t['conv'],2),'roas':round(t['val']/t['cost'],2),'cvr_click':round(t['conv']/t['clicks'],4),'avg_cpc':round(t['cost']/t['clicks'],2)},open(OUT+'evidence/product_campaign_28d_baseline.json','w'),indent=1)
print('keywords',len(krows),'ad groups',len(AG),'ads',len(arows),'negatives',len(nrows),'editor rows',len(erows),'baseline',dict(t))
print('budget total search',sum(c['budget'] for c in C.values()),'+ shopping',C5['budget'])
