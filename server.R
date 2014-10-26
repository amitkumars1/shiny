options(scipen = 10)
library(shiny)
library(ggplot2)
library(xts)

## The following code will execute as the app launches
## Pull the data straight from the website

# code = c("h401","h801" )
# names(code)=c("corn", "soybeans" )
# theurl.corn = paste("http://apps.fas.usda.gov/export-sales/",code[1],".htm",sep="")
# theurl.beans = paste("http://apps.fas.usda.gov/export-sales/",code[2],".htm",sep="")
# exportData.corn = as.data.frame(readHTMLTable(theurl.corn))
# exportData.beans = as.data.frame(readHTMLTable(theurl.beans))
load("./data//exportData.beans.RData")
load("./data//exportData.corn.RData")

## The following code takes the input from the UI.r to display the prediction
shinyServer(
        function(input, output) {
                output$plot <- renderPlot({
                        comdty = input$Commodity
                        field  = input$Field
                        if(comdty =="Soybean"){
                                exportData = na.omit(exportData.corn)
                        }else{
                                exportData = na.omit(exportData.beans)
                        }
                        exportData = exportData[3:NROW(exportData),c(1:5)]
                        colnames(exportData) = c("WeekEnding",  "WeeklyExports",  "AccumulatedExports","NetSales",  
                                                 "OutStandingSales")                        
                        exportDataXTS = NULL
                        WeeklyExports = as.numeric(gsub(pattern=",",replacement="",
                                                        exportData$WeeklyExports))
                        
                        AccumulatedExports = as.numeric(gsub(pattern=",",replacement="",
                                                             exportData$AccumulatedExports))
                        
                        exportData$NetSales = sub(")", "", sub("(", "-", exportData$NetSales, fixed=TRUE), fixed=TRUE)
                        NetSales =   as.numeric(gsub(pattern=",",replacement="",
                                                     exportData$NetSales))
                        
                        OutStandingSales = suppressWarnings(as.numeric(gsub(pattern=",",replacement="",
                                                                            exportData$OutStandingSales)))
                        
                        
                        exportDate = as.Date(exportData$WeekEnding,format="%m/%d/%Y")
                        
                        
                        
                        exportDataXTS = as.xts(cbind(WeeklyExports,AccumulatedExports,NetSales,OutStandingSales),order.by = exportDate)
                        colnames(exportDataXTS) = c("WeeklyExports",  "AccumulatedExports","NetSales",  
                                                    "OutStandingSales") 
                        totalCommitment = exportDataXTS$AccumulatedExports+exportDataXTS$OutStandingSales
                        accExp.totComm = as.numeric(exportDataXTS$AccumulatedExports)/totalCommitment
                        exportDataXTS = cbind(exportDataXTS,totalCommitment,accExp.totComm)
                        colnames(exportDataXTS) = c("WeeklyExports",  "AccumulatedExports","NetSales",  
                                                    "OutStandingSales",
                                                    "totalCommitment","accExp.totComm")
                        
                        myplotData = exportDataXTS[,colnames(exportDataXTS)==field]/1000
                        myplotData <- myplotData[ ! duplicated( index(myplotData) ),  ]
                        from = input$dates[1]
                        to = input$dates[2]
                        
                        myplotData = myplotData[index(myplotData)>=as.Date(from)]
                        myplotData = myplotData[index(myplotData)<=as.Date(to)]
                        myplotData.df = data.frame(date = index(myplotData),value = as.numeric(myplotData))
                        plot.type = input$plottype
                        if(plot.type == "line"){
                                print(ggplot(myplotData.df, aes(x=date,y=value))+
                                              geom_line()+ylab("in thousands of metric tons")+xlab("weekly date index") +theme_bw() + ggtitle(paste(comdty," ",field," timeSeries", sep = ""))+
                                              theme(legend.position="top",legend.title=element_blank(),legend.text = element_text(colour="blue", size = 14, face = "bold")))
                        }else{
                                print(ggplot(myplotData.df, aes(x=date,y=value))+ylab("in thousands of metric tons")+xlab("weekly date index") +
                                              theme_bw()+ggtitle(paste(comdty," ",field," timeSeries", sep = ""))+
                                              geom_bar(stat = "identity"))                      
                        }
                        
                        #                         plot(myplotData, main = paste(comdty," ",field," timeSeries", sep = ""),
                        #                              xlab = "weekly date index", ylab = "in thousands of metric tons")
                        
                        
                })
        }
)


