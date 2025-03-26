from junit_xml import TestSuite, TestCase
from LintFinding import LintFinding


class ParseToJUnit:
    def __init__(self, outputFile):
        self.outputFile = outputFile
        self.cases = []
        self.findingID = 0
            
    def exportLint(self, lint : LintFinding):
        self.findingID = self.findingID + 1
        case = TestCase((str)(self.findingID) + ", " + lint.IDOfFinding + " " + lint.typeOfFinding, lint.fileOfFinding)
        case.add_failure_info(self.__createFailureInfo(lint))
        self.cases.append(case)
    
    def writeCasesToFile(self):
        self.__addPass()
        ts = TestSuite("Static Analysis", self.cases)
        with open(self.outputFile, "w") as g:
            TestSuite.to_file(g,[ts])

    #method to create the Failure info. The failure info is what is shown on bamboo. RETURNS str
    def __createFailureInfo(self, lint : LintFinding):
        return lint.messageOfFinding + " " + self.__printFile(lint) + " " + self.__printLineAndColumn(lint) 

    #method to print line and column with identifiers(not sure whats the best word to use here)
    def __printLineAndColumn(self, lint : LintFinding):
        return "Line: " + lint.lineOfFinding + " Column: " + lint.columnOfFinding

    #method to print the file and word file
    def __printFile(self, lint : LintFinding):
        return "File: " + lint.fileOfFinding

    #necessary since the Bamboo JUnit parse task indicates fail if no tests present
    def __addPass(self):
        if(self.cases.__len__() == 0):
            self.cases.append(TestCase("No Static Analysis Findings"))