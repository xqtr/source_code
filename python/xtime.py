import datetime

def datestr(t):
    if t == 1:
        return datetime.date.today().strftime('%d/%m/%Y')
    elif t == 2:
        return datetime.date.today().strftime('%m/%d/%Y')
    elif t == 3:
        return datetime.date.today().strftime('%Y/%m/%d')
    elif t == 4:
        return datetime.date.today().strftime('%j')
    elif t == 5:
        return datetime.date.today().strftime('%s')
        
def datetimeunix():
    dt = datetime.datetime.now()
    return dt.strftime("%s")
    
def now():
    return datetime.datetime.now()
    
def date():
    return datetime.datetime.today()

def timestr(t):
    if t == 1:
        return datetime.datetime.now().strftime('%H:%M:%S')
    elif t == 2:
        return datetime.datetime.now().strftime('%I:%M:%S %p')
    elif t == 3:
        return datetime.datetime.now().strftime('%H:%M')
    elif t == 4:
        return datetime.datetime.now().strftime('%I:%M %p')
    elif t == 5:
        return datetime.date.today().strftime('%s')
        
def datevalid(date_text):
    res = False
    try:
        datetime.datetime.strptime(date_text, '%d/%m/%Y')
    except ValueError:
        res = False
    if res == True:
        return True
    try:
        datetime.datetime.strptime(date_text, '%m/%d/%Y')
    except ValueError:
        res = False
    if res == True:
        return True  
    try:
        datetime.datetime.strptime(date_text, '%s')
    except ValueError:
        res = False
    if res == True:
        return True 
    try:
        datetime.datetime.strptime(date_text, '%Y/%m/%d')
    except ValueError:
        res = False
    return res        
    
def dayofweek():
    return datetime.date.today().weekday()

def ismdy(date_text):
    res = True
    try:
        datetime.datetime.strptime(date_text, '%m/%d/%Y')
    except ValueError:
        res = False
    return res
    
def isdmy(date_text):
    res = True
    try:
        datetime.datetime.strptime(date_text, '%d/%m/%Y')
    except ValueError:
        res = False
    return res

def isymd(date_text):
    res = True
    try:
        datetime.datetime.strptime(date_text, '%Y/%m/%d')
    except ValueError:
        res = False
    return res  

    
def daysago(date_text):
    if isymd(date_text):
        b = datetime.datetime.strptime(date_text, '%Y/%m/%d')
        
    if isdmy(date_text):
        b = datetime.datetime.strptime(date_text, '%d/%m/%Y')
        
    if ismdy(date_text):
        b = datetime.datetime.strptime(date_text, '%m/%d/%Y')
       
    a = datetime.datetime.today()
    c = abs(a - b)
    return c.days
    
def timer():
    now = datetime.datetime.now()
    midnight = now.replace(hour=0, minute=0, second=0, microsecond=0)
    seconds = (now - midnight).seconds
    return seconds
    
def formatdatetime(form):
    return datetime.datetime.now().strftime(form)
