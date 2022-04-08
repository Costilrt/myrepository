Attribute VB_Name = "Module1"
Sub processSheets()
    'initialize variables
    Dim ws As Integer, sheetCount As Integer
    
    'set sheetCount equal to number of sheets in workbook
    sheetCount = Application.Sheets.Count
    
    'call summarizeStocks sub for each worksheet in workbook
    For ws = 1 To sheetCount
        Worksheets(ws).Activate
        Call summarizeStocks
    Next ws

End Sub

Sub summarizeStocks()

    'declare rawData array and size & looping variables
    Dim rawData() As Variant, rSize As Long, cSize As Integer
    Dim i As Integer, j As Long
    
    'set values to sizing variables (for raw data array)
    cSize = 6
    rSize = ActiveSheet.Cells(Rows.Count, "A").End(xlDown).Row - 1
    
    'resize array
    ReDim rawData(cSize, rSize)
    
    'populate values from sheet to rawData array
    For i = 0 To cSize
        For j = 0 To rSize
            rawData(i, j) = Cells(j + 1, i + 1).Value
        Next j
    Next i
    
    'declare summarizedData array and size & looping variables
    Dim summarizedData() As Variant, colCount As Integer, rowCount As Long
    Dim m As Long
    
    'set values to sizing variables (for summarized data array)
    colCount = 5
    rowCount = 0
    
    'resize array
    ReDim summarizedData(colCount, rowCount)
    
    'process raw data & assign appropriate values to summarizedData array
    For j = 1 To rSize
        For m = 0 To rowCount
            If rawData(0, j) = summarizedData(0, m) Then 'if rawData and summarizedData abbreviations match
                'analyze date to see if it is max or min
                If rawData(1, j) < summarizedData(1, m) Then 'if rawData date is before earliest summarizedData date
                    summarizedData(1, m) = rawData(1, j) 'update summarizedData min date to new min date
                    summarizedData(3, m) = rawData(2, j) 'update summarizedData open price to new open price
                ElseIf rawData(1, j) > summarizedData(2, m) Then 'if rawData date is after latest summarizedData date
                    summarizedData(2, m) = rawData(1, j) 'update summarizedData max date to new max date
                    summarizedData(4, m) = rawData(5, j) 'update summarizedData open price to new open price
                End If
                summarizedData(5, m) = summarizedData(5, m) + rawData(6, j) 'update summarizedData stock volume
                Exit For 'exit loop
            ElseIf m = rowCount Then 'if rawData and summarizedData abbreviations never matched, add as a new abbreviation
                rowCount = rowCount + 1 'increase rowCount to account for new abbreviation added
                ReDim Preserve summarizedData(colCount, rowCount) 'resize summarizedData & preserve all previous data
                summarizedData(0, m + 1) = rawData(0, j) 'add ticker abbreviation
                summarizedData(1, m + 1) = rawData(1, j) 'add date to min date
                summarizedData(2, m + 1) = rawData(1, j) 'add date to max date
                summarizedData(3, m + 1) = rawData(2, j) 'add open price
                summarizedData(4, m + 1) = rawData(5, j) 'add close price
                summarizedData(5, m + 1) = rawData(6, j) 'add volume
                Exit For 'exit loop
            End If
        Next m
    Next j
    
    'call function to add headers for summarized data & max data
    Call addHeaders
    
    'create variables to track calculations
    Dim yearlyChange As Double, percentChange As Double
    
    Dim maxPercentIncrease(1) As Variant, maxPercentDecrease(1) As Variant, maxTotalVolume(1) As Variant
    
    'initialize variables
    maxPercentDecrease(1) = 0
    maxPercentIncrease(1) = 0
    maxTotalVolume(1) = 0
    
    'print summarizedData to sheet
    For m = 1 To rowCount
        Cells(m + 1, 9) = summarizedData(0, m) 'print ticker abbreviation
        yearlyChange = summarizedData(4, m) - summarizedData(3, m) 'calculate the yearly change in a variable so it can be reused & to control decimals (close price - open price)
        Cells(m + 1, 10) = yearlyChange 'print yearly change (close price - open price)
        
        'check that denominator is not equal to zero
        If summarizedData(3, m) = 0 Then
            percentChange = 0 'if denom is zero, then percent change is zero
        Else
            percentChange = yearlyChange / summarizedData(3, m) 'calculate percent change in a variable so max increase & decrease can be calculated
        End If
        
        Cells(m + 1, 11) = percentChange 'print percent change (yearly change / open price)
        Cells(m + 1, 12) = summarizedData(5, m) 'print total stock volume
        
        'identify if ticker's values are max percent increase or decrease
        If percentChange < maxPercentDecrease(1) Then 'if percentChange is less than current maxPercentDecrease
            maxPercentDecrease(0) = summarizedData(0, m) 'assign new ticker
            maxPercentDecrease(1) = percentChange 'assign new maxPercentDecrease
        ElseIf percentChange > maxPercentIncrease(1) Then 'if percentChange is greater than current maxPercentIncrease
            maxPercentIncrease(0) = summarizedData(0, m) 'assign new ticker
            maxPercentIncrease(1) = percentChange 'assign new maxPercentIncrease
        End If
        
        'identify if ticker's values are max total stock volume
        If summarizedData(5, m) > maxTotalVolume(1) Then 'if total stock volume is less than current maxTotalVolume
            maxTotalVolume(0) = summarizedData(0, m) 'assign new ticker
            maxTotalVolume(1) = summarizedData(5, m) 'assign new maxTotalVolume
        End If
    Next m
    
    'print max data to cells
    For i = 0 To 1
        Cells(2, 16 + i) = maxPercentIncrease(i)
        Cells(3, 16 + i) = maxPercentDecrease(i)
        Cells(4, 16 + i) = maxTotalVolume(i)
    Next i
    
    'call function to format all new columns/cells
    Call formatting(rowCount + 1)

End Sub

Sub formatting(rowCount)
    'format Yearly Change and Percent Change with two deicmal places & Percent Change also adds %
    Range("J:J").NumberFormat = "0.00"
    Range("K:K").NumberFormat = "0.00%"
    Range("Q2:Q3").NumberFormat = "0.00%"
    
    'add conditional formatting for negative "Yearly Change" values (RED)
    With Range("J2:J" & rowCount).FormatConditions.Add(xlCellValue, xlLess, "=0")
        .Interior.ColorIndex = 3 'color cells red
    End With
    
    'add conditional formatting for positive/0 "Yearly Change" values (GREEN)
    With Range("J2:J" & rowCount).FormatConditions.Add(xlCellValue, xlGreaterEqual, "=0")
        .Interior.ColorIndex = 4 'color cells green
    End With
    
    'resize new columns
    Columns("I:L").AutoFit
    Columns("O:Q").AutoFit
End Sub

Sub addHeaders()
    'add summarized data headers
    Range("I1").Value = "Ticker Symbol"
    Range("J1").Value = "Yearly Change ($)"
    Range("K1").Value = "Percent Change"
    Range("L1").Value = "Total Stock Volume"
    
    'adding data headers for challenge question
    Range("O2").Value = "Greatest % Increase"
    Range("O3").Value = "Greatest % Decrease"
    Range("O4").Value = "Greatest Total Volume"
    Range("P1").Value = "Ticker"
    Range("Q1").Value = "Value"
End Sub

