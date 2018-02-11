import time
import os, re
import sys
import struct
from pyfiglet import Figlet
import tty,termios
#from future import division

pathchar = os.sep
pathsep  = os.sep

class colors:
    #Colors class:
    #reset all colors with colors.reset
    #two subclasses fg for foreground and bg for background.
    #use as colors.subclass.colorname.
    #i.e. colors.fg.red or colors.bg.green
    #also, the generic bold, disable, underline, reverse, strikethrough,
    #and invisible work with the main class
    #i.e. colors.bold

    reset='\033[0m'
    bold='\033[01m'
    disable='\033[02m'
    underline='\033[04m'
    reverse='\033[07m'
    strikethrough='\033[09m'
    invisible='\033[08m'
    class fg:
        black='\033[30m'
        darkblue='\033[34m'
        darkgreen='\033[32m'
        darkcyan='\033[36m'
        darkred='\033[31m'
        darkmagenta='\033[35m'
        brown='\033[33m'
        grey='\033[0;37m'
        darkgrey='\033[90m'
        lightblue='\033[94m'
        lightgreen='\033[92m'
        lightcyan='\033[96m'
        lightred='\033[91m'
        lightmagenta='\033[95m'        
        yellow='\033[93m'
        white='\033[1;37m'
    class bg:
        black='\033[40m'
        blue='\033[44m'
        green='\033[42m'
        cyan='\033[46m'
        red='\033[41m'
        magenta='\033[45m'
        brown='\033[43m'      
        grey='\033[47m'
        

NextLine = '\033[{n}E'
PrevLine = '\033[{n}F'
curfg = colors.fg.grey
curbg = colors.bg.black
textattr_str = curfg+curbg
textattr = 7

rows, columns = os.popen('stty size', 'r').read().split()
screenheight = int(rows)
screenwidth = int(columns)

def getpos():

    buf = ""
    stdin = sys.stdin.fileno()
    tattr = termios.tcgetattr(stdin)

    try:
        tty.setcbreak(stdin, termios.TCSANOW)
        sys.stdout.write("\x1b[6n")
        sys.stdout.flush()

        while True:
            buf += sys.stdin.read(1)
            if buf[-1] == "R":
                break

    finally:
        termios.tcsetattr(stdin, termios.TCSANOW, tattr)

    # reading the actual values, but what if a keystroke appears while reading
    # from stdin? As dirty work around, getpos() returns if this fails: None
    try:
        matches = re.match(r"^\x1b\[(\d*);(\d*)R", buf)
        groups = matches.groups()
    except AttributeError:
        return None

    return (int(groups[0]), int(groups[1]))
    
def savescreen():
    os.system('tput smcup') #save previous state

def restorescreen():
    os.system('tput rmcup')

def textcolor(c):
    global textattr
    global textattr_str
    global curfg
    global curbg
    textattr = textattr // 16
    textattr = textattr + c
    if c == 0:
        curfg = colors.fg.black
    elif c == 1:
        curfg = colors.fg.darkblue
    elif c == 2:
        curfg = colors.fg.darkgreen
    elif c == 3:
        curfg = colors.fg.darkcyan
    elif c == 4:
        curfg = colors.fg.darkred
    elif c == 5:
        curfg = colors.fg.darkmagenta
    elif c == 6:
        curfg = colors.fg.brown
    elif c == 7:
        curfg = colors.fg.grey
    elif c == 8:
        curfg = colors.fg.darkgrey
    elif c == 9:
        curfg = colors.fg.lightblue
    elif c == 10:
        curfg = colors.fg.lightgreen
    elif c == 11:
        curfg = colors.fg.lightcyan
    elif c == 12:
        curfg = colors.fg.lightred
    elif c == 13:
        curfg = colors.fg.lightmagenta
    elif c == 14:
        curfg = colors.fg.yellow
    elif c == 15:
        curfg = colors.fg.white
    textattr_str = curfg + curbg
    sys.stdout.write(curfg)
    sys.stdout.flush()
    
        
def textbackground(c):
    global textattr
    global textattr_str
    global curfg
    global curbg
    textattr = textattr % 16
    textattr = textattr + (c * 16)
    if c == 0:
        curbg = colors.bg.black
    elif c == 1:
        curbg = colors.bg.blue
    elif c == 2:
        curbg = colors.bg.green
    elif c == 3:
        curbg = colors.bg.cyan
    elif c == 4:
        curbg = colors.bg.red
    elif c == 5:
        curbg = colors.bg.magenta
    elif c == 6:
        curbg = colors.bg.brown
    elif c == 7:
        curbg = colors.bg.grey
    textattr_str = curfg + curbg
    sys.stdout.write(curbg)
    sys.stdout.flush()
    
def textattr2str(a):
    c = a % 16
    d = a // 16
    fg = ''
    bg = ''
    
    if c == 0:
        fg = colors.fg.black
    elif c == 1:
        fg = colors.fg.darkblue
    elif c == 2:
        fg = colors.fg.darkgreen
    elif c == 3:
        fg = colors.fg.darkcyan
    elif c == 4:
        fg = colors.fg.darkred
    elif c == 5:
        fg = colors.fg.darkmagenta
    elif c == 6:
        fg = colors.fg.brown
    elif c == 7:
        fg = colors.fg.grey
    elif c == 8:
        fg = colors.fg.darkgrey
    elif c == 9:
        fg = colors.fg.lightblue
    elif c == 10:
        fg = colors.fg.lightgreen
    elif c == 11:
        fg = colors.fg.lightcyan
    elif c == 12:
        fg = colors.fg.lightred
    elif c == 13:
        fg = colors.fg.lightmagenta
    elif c == 14:
        fg = colors.fg.yellow
    elif c == 15:
        fg = colors.fg.white
        
    if d == 0:
        bg = colors.bg.black
    elif d == 1:
        bg = colors.bg.blue
    elif d == 2:
        bg = colors.bg.green
    elif d == 3:
        bg = colors.bg.cyan
    elif d == 4:
        bg = colors.bg.red
    elif d == 5:
        bg = colors.bg.magenta
    elif d == 6:
        bg = colors.bg.brown
    elif d == 7:
        bg = colors.bg.grey
        
    return fg+bg
        
        
    
def write(s):
    sys.stdout.write(textattr_str)
    sys.stdout.write(str(s))
    sys.stdout.flush()
    
def writeln(st):
    sys.stdout.write(textattr_str)
    sys.stdout.write(str(st)+'\n')
    sys.stdout.flush()
      

def cursorup(n):
    sys.stdout.write('\033['+str(n)+'A')
    sys.stdout.flush()
    
def cursordown(n):
    sys.stdout.write('\033['+str(n)+'B')
    sys.stdout.flush() 
    
def cursorleft(n):
    sys.stdout.write('\033['+str(n)+'D')
    sys.stdout.flush() 
    
def cursorright(n):
    sys.stdout.write('\033['+str(n)+'C')
    sys.stdout.flush() 
    
def cursorblock():
    sys.stdout.write('\033[?112c\007')
    sys.stdout.flush() 

def cursorhalfblock():
    sys.stdout.write('\033[?2c\007');
    sys.stdout.flush()
  

def clrscr():
    sys.stdout.write('\033[2J')
#   n=0 clears from cursor until end of screen,
#   n=1 clears from cursor to beginning of screen
#   n=2 clears entire screen
    sys.stdout.flush()
    gotoxy(1,1)
   
def clreol():
    sys.stdout.write('\033[2K')
#   n=0 clears from cursor to end of line
#   n=1 clears from cursor to start of line
#   n=2 clears entire line
    sys.stdout.flush()

def ansi_on():
    sys.stdout.write('\033(U\033[0m')
    sys.stdout.flush()

def gotox(i):
    sys.stdout.write('\033['+str(i)+'G')
    sys.stdout.flush()
    
def gotoxy(x,y):
    if x < 1:
        x = 1
    if x > 80:
        x = 80
    if y<1:
        y = 1
    if y>25:
        y=25
    sys.stdout.write('\033['+str(y)+';'+str(x)+'H')
    sys.stdout.flush()
    
def settextattr(a):
    global textattr_str
    global textattr
    textattr = a
    textcolor(a % 16)
    textbackground(a // 16)
    
    
def writexy(x,y,a,s):
    gotoxy(x,y)
    sys.stdout.write(textattr2str(a))
    sys.stdout.write(s)
    
def writepipe(txt):
    OldAttr = textattr
    
    width=len(txt)
    Count = 0

    while Count <= len(txt)-1:
        #print str(Count)+' '+str(len(txt))+' '+str(width)
        if txt[Count] == '|':
            Code = txt[Count+1:Count+3]
            CodeNum = int(Code)

            if (Code == '00') or (CodeNum > 0):
                Count = Count +2
                if 0 <= int(CodeNum) < 16:
                    settextattr(int(CodeNum) + ((textattr // 16) * 16))
                else:
                    settextattr((textattr % 16) + (int(CodeNum) - 16) * 16)
            else:
                write(txt[Count:Count+1])
                width = width - 1
      
        else:
            write(txt[Count:Count+1])
            width = width - 1
    

        if width == 0:
            break

        Count +=1
    
    if width > 1:
        write(' '*width)

    
def writexypipe(x,y,attr,width,txt):
    OldAttr = textattr
    OldX    = wherex()
    OldY    = wherey()

    gotoxy(x,y)
    settextattr(attr)

    Count = 0

    while Count <= len(txt)-1:
        #print str(Count)+' '+str(len(txt))+' '+str(width)
        if txt[Count] == '|':
            Code = txt[Count+1:Count+3]
            CodeNum = int(Code)

            if (Code == '00') or (CodeNum > 0):
                Count = Count +2
                if 0 <= int(CodeNum) < 16:
                    settextattr(int(CodeNum) + ((textattr // 16) * 16))
                else:
                    settextattr((textattr % 16) + (int(CodeNum) - 16) * 16)
            else:
                write(txt[Count:Count+1])
                width = width - 1
      
        else:
            write(txt[Count:Count+1])
            width = width - 1
    

        if width == 0:
            break

        Count +=1
    
    if width > 1:
        write(' '*width)

    settextattr(OldAttr)
    gotoxy(OldX, OldY)
    
    
def setwindow(y1,y2):
    sys.stdout.write('\033[' + str(y1) + ';' + str(y2) + 'r');
    sys.stdout.flush()
    
def resetwindow():
    setwindow(1,25)
    
def cls():
    os.system('cls' if os.name == 'nt' else 'clear')
  
def delay(t):
    time.sleep(t/ 1000.0)
    
def savecursor():
    sys.stdout.write('\033[s')

def restorecursor():
    sys.stdout.write('\033[n')
    
def wherex():
    return getpos()[1]
    
def wherey():
    return getpos()[0]
    
def ANSIRender(data):
    """
    Return the .ans file data unpacked & in the correct 437 codepage
    """
    #Check terminal width, a width different to 80 normally causes problems
    #rows, cols = os.popen('stty size', 'r').read().split()
    #if cols != "80":
    #    raw_input("\n[!] The width of the terminal is %s rather than 80, this can often cause bad rendering of the .ANS file. Please adjust terminal width to be 80 and press any key to continue....\n"%(cols))

    ans_out = ""
    for a in data:
        ans_out += chr(struct.unpack("B", a)[0]).decode('cp437')

    return ans_out

def dispfile(filename):
    data = open(filename, "rb").read()
    print ANSIRender(data).encode('cp437')
    
def asciibox(x1,y1,x2,y2,cl):
    gotoxy(x1,y1)
    print cl+'+'+'-'*(x2-x1-1)+'+'
    gotoxy(x1,y2)
    print cl+'+'+'-'*(x2-x1-1)+'+'
    for i in range(y2-y1-1):
        gotoxy(x1,y1+1+i)
        print cl+'|'
        gotoxy(x2,y1+1+i)
        print cl+'|'
        
def ansibox(x1,y1,x2,y2,cl):
    gotoxy(x1,y1)
    print cl+chr(218)+chr(196)*(x2-x1-1)+chr(191)
    gotoxy(x1,y2)
    print cl+chr(192)+chr(196)*(x2-x1-1)+chr(217)
    for i in range(y2-y1-1):
        gotoxy(x1,y1+1+i)
        print cl+chr(179)
        gotoxy(x2,y1+1+i)
        print cl+chr(179)
        
def ansibox2(x1,y1,x2,y2,cl):
    gotoxy(x1,y1)
    print cl+chr(218)+chr(196)*(x2-x1-1)+chr(191)
    gotoxy(x1,y2)
    print cl+chr(192)+chr(196)*(x2-x1-1)+chr(217)
    for i in range(y2-y1-1):
        gotoxy(x1,y1+1+i)
        print cl+chr(179)
        gotoxy(x2,y1+1+i)
        print cl+chr(179)
    gotoxy(x1,y1+1)
    print ':'
    gotoxy(x2,y1+1)
    print ':'
    gotoxy(x1,y2-1)
    print ':'
    gotoxy(x2,y2-1)
    print ':'
    gotoxy(x1+1,y1)
    print chr(250)
    gotoxy(x2-1,y1)
    print chr(250)
    gotoxy(x1+1,y2)
    print chr(250)
    gotoxy(x2-1,y2)
    print chr(249)

def printfiglet(text):
    f = Figlet(font='small')
    print f.renderText(text)
    
def readkey():
    ch1=''
    ch2=''
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(sys.stdin.fileno())
        ch = sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
    return ch
    
def readcursor():
    c = readkey()
    if ord(c) <> 27:
        return None
    c = readkey()
    c = readkey()
    if c=='A':
        return 'Up'
    if c=='B':
        return 'Down'
    if c=='C':
        return 'Right'
    if c=='D':
        return 'Left'
    

def cleararea(x1,y1,x2,y2,bg):
    for i in range(y2-y1):
        gotoxy(x1,y1+i)
        print bg*(x2-x1)
        
