
soorat <- function(x,y) {
  sum=0;
  
  
  for  (i in 1:nrow(data_matrix))
  {
    if ((data_matrix[i,x]==1) & (data_matrix[i,y]==1))
    {
      sum<-sum+capacity[i];
      
    }
  }
  return(sum);
}

makhraj <- function(x) {
  sum=0;
  
  for  (i in 1:nrow(data_matrix))
  {
    if ((data_matrix[i,x]==1))
    {
      sum<-sum+capacity[i];
      
    }
  }
  return(sum);
}


relation<-function()
{ 
  
  capacity<<-rowSums(data_matrix);
  relation_matrix<<-matrix(nrow = ncol(data_matrix),ncol = ncol(data_matrix));
 xxx=0;
  for (i in 1:ncol(data_matrix))
  {
    for (j in 1:ncol(data_matrix))
    {
      sooorat=soorat(i,j);
      relation_matrix[i,j]<<-round(max((sooorat/makhraj(j)),(sooorat/makhraj(i))),digits = 2);
      
        
    }
    print(i);
    
  }
  return(relation_matrix);
}


pruning1<-function(threshold)
{ 
  
  for (i in 1:ncol(data_matrix))
  {
    for (j in 1:ncol(data_matrix))
    {
      
      if ((relation_matrix[i,j]<threshold)  )
        relation_matrix[i,j]=0;
    }
  }
  pruned1<<-matrix(relation_matrix,nrow = ncol(data_matrix),ncol=ncol(data_matrix))
  return("Prune1 DONEee");
}


pruning2<-function()
{ 

  
  graph <- graph.adjacency(pruned1,weighted=TRUE,mode="undirected",diag=FALSE)
  for (i in 1:ncol(data_matrix))
  {
    for (j in 1:ncol(data_matrix))
    {
      if (pruned1[i,j]!=0){
      if (length(all_simple_paths(graph,i,j))==1)
        pruned1[i,j]=0;}
    }
  }
  pruned2<<-matrix(pruned1,nrow = ncol(data_matrix),ncol=ncol(data_matrix))
  return("Prune2 DONE");
}


megiiing<-function()
{ 
  for (i in 1:ncol(data_matrix))
  {
    for (j in 1:ncol(data_matrix))
    {
      
    }
  }
  
}

key_term_R1<-function()
{ 
  R1 <<- array(0,dim=c(11));
  
  for (i in 2:(ncol(data_matrix))){
    for (j in 1:i-1){
      relation_matrix[i,j]<-relation_matrix[j,i];}}
  
  graph <- graph.adjacency(pruned2,weighted=TRUE,mode="undirected",diag=FALSE);
  cluster<-clusters(graph,mode="strong");
  for (i in 1:ncol(data_matrix))
  {
    for (j in 1:ncol(data_matrix))
    {
      
        if (cluster$membership[i]!=cluster$membership[j])
          R1[i]<<-R1[i]+relation_matrix[i,j];
    }
  }
 
  return("key_term extraction DONE");
}



key_term_R2<-function()
{ 
  R2 <<- array(0,dim=c(11));
  ci<-0;

  for (i in 2:(ncol(data_matrix))){
    for (j in 1:i-1){
      relation_matrix[i,j]<-relation_matrix[j,i];}}
  
  graph <- graph.adjacency(pruned2,weighted=TRUE,mode="undirected",diag=FALSE);
  cluster<-clusters(graph,mode="strong");
  for (i in 1:ncol(data_matrix))
  {
    for (j in 1:ncol(data_matrix))
    {
      
      if (cluster$membership[i]!=cluster$membership[j])
      {
        ci<-cluster$membership[j];
        si<-0;
        
        
        nprimt<-0;
          for (t in 1:ncol(data_matrix) )
          {   
               
          
              
              if (cluster$membership[t]==ci)
              {
                si<-si+co_occurrence[i,t];
                nprimt<-nprimt+co_occurrence[t,t];
               
                
              }
            
          }
        pttt<-0;
        
       
        for (t in 1:ncol(data_matrix) )
        {   
          
          
          
          if (cluster$membership[t]==ci)
          {
            pttt<-co_occurrence[t,t]/nprimt;
           
            
            R2[i]<<-R2[i]+(((co_occurrence[i,t]-(si*pttt))^2)/(si*pttt));
            
            
          }
          
        }
       
        
      }
      if (R2[i]!=0 | is.nan(R2[i])){
        break}
     
    }
   
  }
  
  return("key_term extraction2 DONE");
}

