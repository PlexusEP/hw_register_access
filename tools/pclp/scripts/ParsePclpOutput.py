import json
from LintFinding import LintFinding 

class ParsePclpOutput:
    def __init__(self, inputFile, schemaFile):
        self.PCLPOutputFile = open(inputFile)
        with open(schemaFile) as g:
            self.schemaFile = json.load(g)
        
        self.firstMessage = True
        self.lines = []
        

    def __parseFinding(self):
        currentLint = None
        currentLint = LintFinding(self.lines[self.schemaFile["File"]['line'] - 1].split()[self.schemaFile['File']['item'] - 1][:-1])
        currentLint.lineOfFinding = self.lines[self.schemaFile["LineInCode"]['line'] - 1].split()[self.schemaFile['LineInCode']['item'] - 1][:-1]
        currentLint.columnOfFinding = self.lines[self.schemaFile["Column"]['line'] - 1].split()[self.schemaFile['Column']['item'] - 1]
        currentLint.typeOfFinding = self.lines[self.schemaFile["Type"]['line'] - 1].split()[self.schemaFile['Type']['item'] - 1][:-1]
        currentLint.IDOfFinding = self.lines[self.schemaFile["ID"]['line'] - 1].split()[self.schemaFile['ID']['item'] - 1][:-1]
        currentLint.messageOfFinding = self.lines[self.schemaFile["Message"]['line'] - 1].split(',')[self.schemaFile["Message"]["item"] -1]
        currentLint.lineOfCode = self.lines[self.schemaFile["Code"]['line'] - 1]
        currentLint.carrotLine = self.lines[self.schemaFile["Carrot"]['line'] - 1]
        del self.lines[:self.lines.__len__() - 1]
        return currentLint

    def nextLint(self):
        for line in self.PCLPOutputFile:
            if self.schemaFile["StartDelimiter"] in line.split():
                if not self.firstMessage:
                    self.lines.append(line)
                    return self.__parseFinding()
                self.lines = []
                self.lines.append(line)
                self.firstMessage = False   
            else:
                self.lines.append(line)
        
        try:
         if not self.firstMessage:
            return self.__parseFinding()
        except:
         return None
        
        