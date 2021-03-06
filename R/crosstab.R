#' Function for creating a crosstabs
#'
#' This function creates crosstabs in a flexible manner.
#' @param data data frame to be analyzed
#' @param row.vars A single or vector of row variables, quoted.
#' @param col.vars A single or vector of column variables, quoted
#' @param format  "freq", "col_percent", "row_percent", "total_percent"
#' @param useNA  "ifany", "no", "always"
#' @param title  string Title to be used for printing
#' @param row.margin.format  "percent" to show row percents, "freq" to show row frequency, "none" for no margin
#' @param col.margin.format "percent" to show percents, "freq" to show column frequencies, "none" for no margin
#' @param dnames vector Dimension names to replace the variable names.
#' @param pretty.print logical TRUE means to add linebreaks for printing with Pander or another package.
#' @param row.margin Indicates whether or not row margins should be displayed.
#' @keywords crosstab
#' @export

crosstab<-function(data, row.vars = "",
                    col.vars = "",
                    format = "freq",
                    useNA = "ifany",
                    title = "",
                    row.margin = TRUE,
                    row.margin.format = "none",
                    col.margin.format = "freq",
                    dnames = "",
                    pretty.print = FALSE
                    ){

    factorsToUse <- c(row.vars, col.vars)

    # Deal with case where row.vars or col.vars is empty.
    factorsToUse <- factorsToUse[factorsToUse != ""]
    nvars <- length(factorsToUse)
    if (nvars == 0 ){
        return("No variables were specified")
    }

    if (nvars == 1) {
        onedtable <- soctable::frequency(data[factorsToUse])
        return(onedtable)
    }
    # Deal with spaces in variable name, but make it backward compatible.
    if (grepl(" ", factorsToUse) == TRUE && substr(factorsToUse, 1, 1) != "`") {
            factorsToUse<-paste0("`",factorsToUse,"`")
        }
    else {
            factorsToUse <- factorsToUse
        }

    form<-stats::as.formula(paste(" ~", paste(factorsToUse, collapse="+"), sep=""))

    tab<-tabf<-stats::xtabs( form, data = data)

    # Preprocess larger tables down to 2 variables
    if (nvars > 2) {
        # This is for 3+ variables, basically we make it be 2 variables.
        tab<-as.data.frame(tab)

        cname <- paste(col.vars, collapse = " ")
        rname<-paste(row.vars, collapse = " ")

        # Merge the labels for the column variables into a single label with line breaks.
        if (length(col.vars) > 1  ) {
            septouse = ifelse(pretty.print, "\\\n", " ")
            tab$colvars <-with(tab, paste(tab[,length(row.vars)+1],tab[,nvars], sep = septouse))

        } else {
            tab$colvars <-with(tab,tab[,length(row.vars) +1])
        }

        # Merge the labels for row variables into a single label with a space.
        if (length(row.vars) > 1){
            tab$rowvars <- paste(tab[,1], tab[,length(row.vars)], sep = " ")
            #tab$rowvars <- paste(selectcols, collapse = " ")
        } else {
            tab$rowvars <- with(tab,tab[,row.vars])
        }

        names(dimnames(tab))<-list(rname, cname)
    }

    if (length(factorsToUse) > 2) {
        # this is for 3+ variables, basically we make it be 2 variables
        tab<-as.data.frame(tab)

        cname <- paste(col.vars, collapse = " ")
        rname <- paste(row.vars, collapse = " ")

        # Merge the labels for the column variables into a single label with line breaks.
        if (length(col.vars) > 1  ) {
            septouse = ifelse(pretty.print, "\\\n", " ")
            tab$colvars <-with(tab, paste(tab[,length(row.vars)+1],tab[,nvars], sep = septouse))

        } else {
            tab$colvars <-with(tab,tab[,length(row.vars) +1])
        }

        # Merge the labels for row variables into a single label with a space.
        if (length(row.vars) > 1){
            tab$rowvars <- paste(tab[,1], tab[,length(row.vars)], sep = " ")
        } else {
            tab$rowvars <- with(tab,tab[,row.vars])
        }

        names(dimnames(tab))<-list(rname, cname)
        form <- stats::as.formula(paste0("Freq ~ rowvars + colvars"))
        tabf<-tab<-stats::xtabs(form, tab)
    }

    # Now process everything as though it is a two way table.
    #tabf<-tab<-xtabs(form, tab)
    tabn<-margin.table(tabf)
    margin.row.f<-margin.table(tabf,1)
    margin.row.p<-prop.table(margin.row.f)
    margin.col.f<-margin.table(tabf,2)
    margin.col.p<-prop.table(margin.col.f)
    margins<-list(row.freq = margin.row.f,
                  row.prop = margin.row.p,
                  col.freq = margin.col.f,
                  col.prop = margin.col.p)
    if (format == "column_percent" | format == "col_percent"){
        tab<-round(prop.table(tabf, 2)*100, 1)
    } else if (format == "row_percent"){
        tab<-round(prop.table(tabf, 1)*100, 1)
    } else if (format == "total_percent"){
        tab<-round(100*tabf/sum(tabf), 1)
    }
    # Change to a data frame to make it more flexible
    tab<-as.data.frame.matrix(tab)
    for(i in c(1:ncol(tab))) {
        tab[,i] <- as.character(tab[,i])
    }

        # Add requested marginals
        if (row.margin.format != "none") {
            if (row.margin.format == 'percent'){
               tab$Total <- round(100*margin.row.p, 1)
            } else {
                tab$Total <- margin.row.f
            }
            tab$Total <- as.character(tab$Total)
        }

         if (col.margin.format != "none") {
         if (col.margin.format == 'percent'){
             cm<-as.character(round(100*margin.col.p, 1))
             rn<-"Row Percent"
         } else {
             cm<-margin.col.f
             rn<-"Total N"
         }
        if (row.margin){
            cm<-c(cm, tabn)
        }
         tab<-rbind(tab,cm)
         rownames(tab)[nrow(tab)]<-rn

    }
    crosstab<-list(tabf=tabf,
                   tab = tab,
                   n = tabn,
                   title = title,
                   margins = margins,
                   factors = factorsToUse,
                   formula = form
                    )
    class(crosstab)<-c("crosstab")

    crosstab

}
