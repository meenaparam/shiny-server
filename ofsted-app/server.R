# Title: Shiny Server Logic for Ofsted grade predictor 
# Author: Meenakshi Parameshwaran
# Date: 04/03/2016

# Load necessary packages
library(shiny)
library(knitr)
library(caret)
library(tidyr)
library(ggplot2)
#library(rCharts)
library(scales)
library(randomForest)
library(klaR)

# Set working directory for testing
# setwd("~/GitHub/Ofsted_Prediction/Ofsted_App")

# Load up the ofsted data
schools <- readRDS(file = "schools.RDS")

# Load model objects
modellda <- readRDS(file = "models/modellda.RDS")
modelnb <- readRDS(file = "models/modelnb.RDS")
modelrf <- readRDS(file = "models/modelrf.RDS")
modelknn <- readRDS(file = "models/modelknn.RDS")

# Set up the server logic for the Ofsted predictor classifier
shinyServer(function(input, output) {
    
        observe({

            # apply selected classification algorithm
            if(input$algorithm=="Linear Discriminant Analysis"){
                
                # Reactively update the prediction dataset!
                values <- reactiveValues()
                values$df <- data.frame(ks2aps = NA,
                                        totpups = NA,
                                        reldenom = NA,
                                        egender = NA,
                                        region = NA,
                                        instype = NA
                                        )
                newEntry <- observe({
                    values$df$ks2aps <- input$ks2aps
                    values$df$totpups <- input$totpups
                    values$df$reldenom <- input$reldenom
                    values$df$egender <- input$egender
                    values$df$region <- input$region
                    values$df$instype <- input$instype
                    
                })
                
                    # make and print the plot
                    output$predplot <- renderPlot({
                    
                    mypred <- reactive(predict.train(modellda, newdata = data.frame(values$df), type = "prob"))
                    finalpred <- mypred()
                    print(finalpred)
                    
                    mypred1 <- tidyr::gather(data = finalpred, key = ofstedgrade, value = probability)
                    
                     gg <- ggplot(data = mypred1, aes(x = factor(ofstedgrade), y = probability, fill = factor(ofstedgrade))) + geom_bar(stat = "identity")  + scale_x_discrete(limits = c("Outstanding", "Good", "Requires Improvement", "Inadequate")) + scale_y_continuous(labels=percent) + geom_text(aes(label = paste0(round(probability*100, 0),"%")), position = position_dodge(0.9), vjust = -1, size = 4) + xlab("Ofsted grade") + ylab("Probability") + guides(fill=FALSE) + theme(axis.text=element_text(size=12), axis.title=element_text(size=14,face="bold")) + coord_cartesian(ylim = c(0,1))
                    
                    print(gg)
                    
                })
                    
                        #rChart version - not used for now
                        # output$myChart <- renderChart({
                        #
                        # mypred <- reactive(predict.train(modellda, newdata = data.frame(values$df), type = "prob"))
                        # finalpred <- mypred()
                        # print(finalpred)
                        #
                        # mypred1 <- tidyr::gather(data = finalpred, key = ofstedgrade, value = probability)
                        #
                        # p1 <- rPlot(x = "ofstedgrade", y = "probability", data = mypred1, color = "ofstedgrade", type = 'bar')
                        # p1$addParams(dom = "myChart")
                        # p1$set(legendPosition = "none")
                        # return(p1)
                        #
                    # })

            } else if(input$algorithm=="Naive Bayes"){

                # Reactively update the prediction dataset!
                values <- reactiveValues()
                values$df <- data.frame(ks2aps = NA,
                                        totpups = NA,
                                        reldenom = NA,
                                        egender = NA,
                                        region = NA,
                                        instype = NA
                )
                newEntry <- observe({
                    values$df$ks2aps <- input$ks2aps
                    values$df$totpups <- input$totpups
                    values$df$reldenom <- input$reldenom
                    values$df$egender <- input$egender
                    values$df$region <- input$region
                    values$df$instype <- input$instype

                })

                # make and print the plot
                output$predplot <- renderPlot({

                    mypred <- reactive(predict.train(modelnb, newdata = data.frame(values$df), type = "prob"))
                    finalpred <- mypred()
                    print(finalpred)

                    mypred1 <- tidyr::gather(data = finalpred, key = ofstedgrade, value = probability)

                    gg <- ggplot(data = mypred1, aes(x = factor(ofstedgrade), y = probability, fill = factor(ofstedgrade))) + geom_bar(stat = "identity")  + scale_x_discrete(limits = c("Outstanding", "Good", "Requires Improvement", "Inadequate")) + scale_y_continuous(labels=percent) + geom_text(aes(label = paste0(round(probability*100, 0),"%")), position = position_dodge(0.9), vjust = -1, size = 4) + xlab("Ofsted grade") + ylab("Probability") + guides(fill=FALSE) + theme(axis.text=element_text(size=12), axis.title=element_text(size=14,face="bold")) + coord_cartesian(ylim = c(0,1))

                    print(gg)

                })
            } else if(input$algorithm=="Random Forest"){

                # Reactively update the prediction dataset!
                values <- reactiveValues()
                values$df <- data.frame(ks2aps = NA,
                                        totpups = NA,
                                        reldenom = NA,
                                        egender = NA,
                                        region = NA,
                                        instype = NA
                )
                newEntry <- observe({
                    values$df$ks2aps <- input$ks2aps
                    values$df$totpups <- input$totpups
                    values$df$reldenom <- input$reldenom
                    values$df$egender <- input$egender
                    values$df$region <- input$region
                    values$df$instype <- input$instype

                })

                # make and print the plot
                output$predplot <- renderPlot({

                    mypred <- reactive(predict.train(modelrf, newdata = data.frame(values$df), type = "prob"))
                    finalpred <- mypred()
                    print(finalpred)

                    mypred1 <- tidyr::gather(data = finalpred, key = ofstedgrade, value = probability)

                    gg <- ggplot(data = mypred1, aes(x = factor(ofstedgrade), y = probability, fill = factor(ofstedgrade))) + geom_bar(stat = "identity")  + scale_x_discrete(limits = c("Outstanding", "Good", "Requires Improvement", "Inadequate")) + scale_y_continuous(labels=percent) + geom_text(aes(label = paste0(round(probability*100, 0),"%")), position = position_dodge(0.9), vjust = -1, size = 4) + xlab("Ofsted grade") + ylab("Probability") + guides(fill=FALSE) + theme(axis.text=element_text(size=12), axis.title=element_text(size=14,face="bold")) + coord_cartesian(ylim = c(0,1))

                    print(gg)

                })

            } else if(input$algorithm=="K-Nearest Neighbours"){

                # Reactively update the prediction dataset!
                values <- reactiveValues()
                values$df <- data.frame(ks2aps = NA,
                                        totpups = NA,
                                        reldenom = NA,
                                        egender = NA,
                                        region = NA,
                                        instype = NA
                )
                newEntry <- observe({
                    values$df$ks2aps <- input$ks2aps
                    values$df$totpups <- input$totpups
                    values$df$reldenom <- input$reldenom
                    values$df$egender <- input$egender
                    values$df$region <- input$region
                    values$df$instype <- input$instype

                })

                # make and print the plot
                output$predplot <- renderPlot({

                    mypred <- reactive(predict.train(modelknn, newdata = data.frame(values$df), type = "prob"))
                    finalpred <- mypred()
                    print(finalpred)

                    mypred1 <- tidyr::gather(data = finalpred, key = ofstedgrade, value = probability)

                    gg <- ggplot(data = mypred1, aes(x = factor(ofstedgrade), y = probability, fill = factor(ofstedgrade))) + geom_bar(stat = "identity")  + scale_x_discrete(limits = c("Outstanding", "Good", "Requires Improvement", "Inadequate")) + scale_y_continuous(labels=percent) + geom_text(aes(label = paste0(round(probability*100, 0),"%")), position = position_dodge(0.9), vjust = -1, size = 4) + xlab("Ofsted grade") + ylab("Probability") + guides(fill=FALSE) + theme(axis.text=element_text(size=12), axis.title=element_text(size=14,face="bold")) + coord_cartesian(ylim = c(0,1))

                    print(gg)

                })
            }else{
                output$results <- renderPrint("Error no Algorithm selected")
        }

        })

})
