
import java.awt.List;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;







public class multi {
	static int docTermSize;
	public double [] relationMatrix;
	public  HashMap<String,ArrayList<Double>> merged=new HashMap<String,ArrayList<Double>>();
	private  HashMap<Integer,ArrayList<Integer>> memory=new HashMap<Integer,ArrayList<Integer>>();
	static DecimalFormat df = new DecimalFormat("#0.0");
	static DecimalFormat dfForSemanticRelation = new DecimalFormat("#0.000000");
	private static ArrayList<String> unioned;
	int[][] data_matrix;
	double[] makhraj;
	public int[] capacity;
	public ArrayList<String> semanticRelation;
	//public double[] relationMatrix;
	public boolean[] flag;
	public ArrayList<String> documentTerms;
	//commit test
	public multi(ArrayList<String> semanticRelation,double[] relationMatrix,ArrayList<String> documentTerms)
	{
		
		this.semanticRelation=semanticRelation;
		this.relationMatrix=relationMatrix;
		this.documentTerms=documentTerms;
	}
	
	public multi(int[] capacity)
	{
		
		this.capacity=capacity;
	}
			
			public  class Thread11 extends Thread {
				LinkedHashMap<ArrayList<Integer>, Integer> linkfrequency;
				int[][] data_matrix;
				double[] makhraj;
				Map index;
				ArrayList<String> documentTerms;
				public Thread11(LinkedHashMap<ArrayList<Integer>, Integer> linkfrequency2,int[][]data_matrix,double[] makhraj,Map index,ArrayList<String>documentTerms)
				{
					this.linkfrequency=linkfrequency2;
					this.data_matrix=data_matrix;
					this.makhraj=makhraj;
					this.index=index;
					this.documentTerms=documentTerms;
			
				}
				
				@Override
				public void run()
				{
					//int end=(int) ((docTermSize)/(2*Math.sqrt(2.0)));
					int end=(linkfrequency.size()/8);
		  		 for (int i=0;i<=end;++i)
					{
//		  			 if (linkfrequency[i][2]>=Main.linkFrequnecyParameter)
//		  			 {
		  				
		  			 	Set<ArrayList<Integer>> keys = linkfrequency.keySet();
		  			 	Object[] keyarray = keys.toArray();
		  			 	ArrayList<Integer> x =(ArrayList<Integer>) keyarray[i];
		  			 	
		  			 	int term_i_int = x.get(0);
		  			 	int term_j_int = x.get(1);
		  			 	
		  				double makhraj_i=makhraj[term_i_int];
		  				double makhraj_j=makhraj[term_j_int];
		  				
		  				InvertedIndex object=new InvertedIndex();
		  				
		  				String term_i = documentTerms.get(term_i_int);
		  				String term_j = documentTerms.get(term_j_int);
		  				
		  				Set Set_i = object.search(term_i,index);
		  				Set Set_j = object.search(term_j,index);
		  				
		  				
						double soorat=soorat(Set_i,Set_j);
						double relationsss=Double.parseDouble((df.format((Math.max(((double)soorat/makhraj_i),(double)soorat/makhraj_j)))));
				
						if (relationsss>=Main.link_relation)
							{
								relationMatrix[i]=relationsss;
								//relationMatrix[j][i]=relationsss;
							
							}
							else 
							{
								relationMatrix[i]= 0.0;
								//relationMatrix[j][i]=0.0;
								
							}	  	
						
					}
		  		System.out.println("thread 1 done");
			}

				
		}
			
			public  class Thread12 extends Thread {
				LinkedHashMap<ArrayList<Integer>,Integer> linkfrequency;
				int[][] data_matrix;
				double[] makhraj;
				Map index;
				ArrayList<String> documentTerms;
				public Thread12(LinkedHashMap<ArrayList<Integer>,Integer> linkfrequency2,int[][]data_matrix,double[] makhraj,Map index,ArrayList<String>documentTerms)
				{
					this.linkfrequency=linkfrequency2;
					this.data_matrix=data_matrix;
					this.makhraj=makhraj;
					this.index=index;
					this.documentTerms=documentTerms;
			
				}
				
				@Override
				public void run()
				{
					int start=(linkfrequency.size()/8)+1;
					int end	= 2*(linkfrequency.size()/8);
		  		 for (int i=start;i<=end;++i)
					{
		  			{
//			  			 if (linkfrequency[i][2]>=Main.linkFrequnecyParameter)
//			  			 {
		  				Set<ArrayList<Integer>> keys = linkfrequency.keySet();
		  			 	Object[] keyarray = keys.toArray();
		  			 	ArrayList<Integer> x =(ArrayList<Integer>) keyarray[i];
		  			 	
		  			 	int term_i_int = x.get(0);
		  			 	int term_j_int = x.get(1);
		  			 	
		  				double makhraj_i=makhraj[term_i_int];
		  				double makhraj_j=makhraj[term_j_int];
		  				
		  				InvertedIndex object=new InvertedIndex();
		  				
		  				String term_i = documentTerms.get(term_i_int);
		  				String term_j = documentTerms.get(term_j_int);
		  				
		  				Set Set_i = object.search(term_i,index);
		  				Set Set_j = object.search(term_j,index);
		  				
				  		double soorat=soorat(Set_i,Set_j);
						double relationsss=Double.parseDouble((df.format((Math.max(((double)soorat/makhraj_i),(double)soorat/makhraj_j)))));
							if (relationsss>=Main.link_relation)
								{
								relationMatrix[i]=relationsss;
									//relationMatrix[j][i]=relationsss;
								
								}
								else 
								{
									relationMatrix[i]=0.0;				
									
								}
		  	
							
						}
						
					}
		  		System.out.println("thread 2 done");
			}
		}
			public  class Thread13 extends Thread {
				LinkedHashMap<ArrayList<Integer>,Integer> linkfrequency;
				int[][] data_matrix;
				double[] makhraj;
				Map index;
				ArrayList<String> documentTerms;
				public Thread13(LinkedHashMap<ArrayList<Integer>,Integer> linkfrequency2,int[][]data_matrix,double[] makhraj,Map index,ArrayList<String>documentTerms)
				{
					this.linkfrequency=linkfrequency2;
					this.data_matrix=data_matrix;
					this.makhraj=makhraj;
					this.index=index;
					this.documentTerms=documentTerms;
			
				}
				
				@Override
		public void run()
		{
					int start=(2*(linkfrequency.size()/8))+1;
					int end	= 3*(linkfrequency.size()/8);
  		 for (int i=start;i<=end;++i)
  		{
//  			 if (linkfrequency[i][2]>=Main.linkFrequnecyParameter)
//  			 {
  			Set<ArrayList<Integer>> keys = linkfrequency.keySet();
			 	Object[] keyarray = keys.toArray();
			 	ArrayList<Integer> x =(ArrayList<Integer>) keyarray[i];
			 	
			 	int term_i_int = x.get(0);
			 	int term_j_int = x.get(1);
			 	
				double makhraj_i=makhraj[term_i_int];
				double makhraj_j=makhraj[term_j_int];
				
				InvertedIndex object=new InvertedIndex();
				
				String term_i = documentTerms.get(term_i_int);
				String term_j = documentTerms.get(term_j_int);
				
				Set Set_i = object.search(term_i,index);
				Set Set_j = object.search(term_j,index);
				
				
	  			double soorat=soorat(Set_i,Set_j);
				double relationsss=Double.parseDouble((df.format((Math.max(((double)soorat/makhraj_i),(double)soorat/makhraj_j)))));
				if (relationsss>=Main.link_relation)
					{
						relationMatrix[i]=relationsss;
						//relationMatrix[j][i]=relationsss;
					
					}
					else 
					{
						relationMatrix[i]=0.0;
						//relationMatrix[j][i]=0.0;
						
					}
				
			}
  		System.out.println("thread 3 done");
	}
}
			public  class Thread14 extends Thread {
				LinkedHashMap<ArrayList<Integer>,Integer> linkfrequency;
				int[][] data_matrix;
				double[] makhraj;
				Map index;
				ArrayList<String> documentTerms;
				public Thread14(LinkedHashMap<ArrayList<Integer>,Integer> linkfrequency2,int[][]data_matrix,double[] makhraj,Map index,ArrayList<String>documentTerms)
				{
					this.linkfrequency=linkfrequency2;
					this.data_matrix=data_matrix;
					this.makhraj=makhraj;
					this.index=index;
					this.documentTerms=documentTerms;
			
				}
				@Override
		public void run()
		{
					int start=(3*(linkfrequency.size()/8))+1;
					int end	= 4*(linkfrequency.size()/8);
  		 for (int i=start;i<=end;++i)
  		{
//  			 if (linkfrequency[i][2]>=Main.linkFrequnecyParameter)
//  			 {
  			Set<ArrayList<Integer>> keys = linkfrequency.keySet();
			 	Object[] keyarray = keys.toArray();
			 	ArrayList<Integer> x =(ArrayList<Integer>) keyarray[i];
			 	
			 	int term_i_int = x.get(0);
			 	int term_j_int = x.get(1);
			 	
				double makhraj_i=makhraj[term_i_int];
				double makhraj_j=makhraj[term_j_int];
				
				InvertedIndex object=new InvertedIndex();
				
				String term_i = documentTerms.get(term_i_int);
				String term_j = documentTerms.get(term_j_int);
				
				Set Set_i = object.search(term_i,index);
				Set Set_j = object.search(term_j,index);
				
	  			double soorat=soorat(Set_i,Set_j);
				double relationsss=Double.parseDouble((df.format((Math.max(((double)soorat/makhraj_i),(double)soorat/makhraj_j)))));
				if (relationsss>=Main.link_relation)
					{
						relationMatrix[i]=relationsss;
						//relationMatrix[j][i]=relationsss;
					
					}
					else 
					{
						relationMatrix[i]=0.0;
						//relationMatrix[j][i]=0.0;
						
					}
  			
//			
//			
			}
  		System.out.println("thread 4 done");
	}
}
			public  class Thread15 extends Thread {
				LinkedHashMap<ArrayList<Integer>,Integer> linkfrequency;
				int[][] data_matrix;
				double[] makhraj;
				Map index;
				ArrayList<String> documentTerms;
				public Thread15(LinkedHashMap<ArrayList<Integer>,Integer> linkfrequency2,int[][]data_matrix,double[] makhraj,Map index,ArrayList<String>documentTerms)
				{
					this.linkfrequency=linkfrequency2;
					this.data_matrix=data_matrix;
					this.makhraj=makhraj;
					this.index=index;
					this.documentTerms=documentTerms;
			
				}
				@Override
				public void run()
				{
					int start=(4*(linkfrequency.size()/8))+1;
					int end	= 5*(linkfrequency.size()/8);
		  		 for (int i=start;i<=end;++i)
		  		{
//		  			 if (linkfrequency[i][2]>=Main.linkFrequnecyParameter)
//		  			 {
			  			Set<ArrayList<Integer>> keys = linkfrequency.keySet();
		  			 	Object[] keyarray = keys.toArray();
		  			 	ArrayList<Integer> x =(ArrayList<Integer>) keyarray[i];
		  			 	
		  			 	int term_i_int = x.get(0);
		  			 	int term_j_int = x.get(1);
		  			 	
		  				double makhraj_i=makhraj[term_i_int];
		  				double makhraj_j=makhraj[term_j_int];
		  				
		  				InvertedIndex object=new InvertedIndex();
		  				
		  				String term_i = documentTerms.get(term_i_int);
		  				String term_j = documentTerms.get(term_j_int);
		  				
		  				Set Set_i = object.search(term_i,index);
		  				Set Set_j = object.search(term_j,index);
	  				
			  			double soorat=soorat(Set_i,Set_j);
						double relationsss=Double.parseDouble((df.format((Math.max(((double)soorat/makhraj_i),(double)soorat/makhraj_j)))));
						if (relationsss>=Main.link_relation)
							{
								relationMatrix[i]=relationsss;
								//relationMatrix[j][i]=relationsss;
							
							}
							else 
							{
								relationMatrix[i]=0.0;
								//relationMatrix[j][i]=0.0;
								
							}
//		  			 }
//		  			
					}
		  		System.out.println("thread 5 done");
			}
		}
			public  class Thread16 extends Thread {
				LinkedHashMap<ArrayList<Integer>,Integer> linkfrequency;
				int[][] data_matrix;
				double[] makhraj;
				Map index;
				ArrayList<String> documentTerms;
				public Thread16(LinkedHashMap<ArrayList<Integer>,Integer> linkfrequency2,int[][]data_matrix,double[] makhraj,Map index,ArrayList<String>documentTerms)
				{
					this.linkfrequency=linkfrequency2;
					this.data_matrix=data_matrix;
					this.makhraj=makhraj;
					this.index=index;
					this.documentTerms=documentTerms;
			
				}
				@Override
				public void run()
				{
					int start=(5*(linkfrequency.size()/8))+1;
					int end	= 6*(linkfrequency.size()/8);
		  		 for (int i=start;i<=end;++i)
		  		{
//		  			 if (linkfrequency[i][2]>=Main.linkFrequnecyParameter)
//		  			 {
			  			Set<ArrayList<Integer>> keys = linkfrequency.keySet();
		  			 	Object[] keyarray = keys.toArray();
		  			 	ArrayList<Integer> x =(ArrayList<Integer>) keyarray[i];
		  			 	
		  			 	int term_i_int = x.get(0);
		  			 	int term_j_int = x.get(1);
		  			 	
		  				double makhraj_i=makhraj[term_i_int];
		  				double makhraj_j=makhraj[term_j_int];
		  				
		  				InvertedIndex object=new InvertedIndex();
		  				
		  				String term_i = documentTerms.get(term_i_int);
		  				String term_j = documentTerms.get(term_j_int);
		  				
		  				Set Set_i = object.search(term_i,index);
		  				Set Set_j = object.search(term_j,index);
			  			double soorat=soorat(Set_i,Set_j);
						double relationsss=Double.parseDouble((df.format((Math.max(((double)soorat/makhraj_i),(double)soorat/makhraj_j)))));
						if (relationsss>=Main.link_relation)
							{
								relationMatrix[i]=relationsss;
								//relationMatrix[j][i]=relationsss;
							
							}
							else 
							{
								relationMatrix[i]=0.0;
								//relationMatrix[j][i]=0.0;
								
							}
 		
						
					}
		  		System.out.println("thread 6 done");
			}
		}
			public  class Thread17 extends Thread {
				LinkedHashMap<ArrayList<Integer>,Integer> linkfrequency;
				int[][] data_matrix;
				double[] makhraj;
				Map index;
				ArrayList<String> documentTerms;
				public Thread17(LinkedHashMap<ArrayList<Integer>,Integer> linkfrequency2,int[][]data_matrix,double[] makhraj,Map index,ArrayList<String>documentTerms)
				{
					this.linkfrequency=linkfrequency2;
					this.data_matrix=data_matrix;
					this.makhraj=makhraj;
					this.index=index;
					this.documentTerms=documentTerms;
			
				}
				@Override
				public void run()
				{
					int start=(6*(linkfrequency.size()/8))+1;
					int end	= 7*(linkfrequency.size()/8);
		  		 for (int i=start;i<=end;++i)
		  		{
//		  			 if (linkfrequency[i][2]>=Main.linkFrequnecyParameter)
//		  			 {
		  				//ArrayList<Integer> listA = makhraj (linkfrequency[i][0]);
			  				//int makhraj_i=listA.get(listA.size()-1);
			  			Set<ArrayList<Integer>> keys = linkfrequency.keySet();
		  			 	Object[] keyarray = keys.toArray();
		  			 	ArrayList<Integer> x =(ArrayList<Integer>) keyarray[i];
		  			 	
		  			 	int term_i_int = x.get(0);
		  			 	int term_j_int = x.get(1);
		  			 	
		  				double makhraj_i=makhraj[term_i_int];
		  				double makhraj_j=makhraj[term_j_int];
		  				
		  				InvertedIndex object=new InvertedIndex();
		  				
		  				String term_i = documentTerms.get(term_i_int);
		  				String term_j = documentTerms.get(term_j_int);
		  				
		  				Set Set_i = object.search(term_i,index);
		  				Set Set_j = object.search(term_j,index);
	  				
			  			double soorat=soorat(Set_i,Set_j);
						double relationsss=Double.parseDouble((df.format((Math.max(((double)soorat/makhraj_i),(double)soorat/makhraj_j)))));
						if (relationsss>=Main.link_relation)
							{
								relationMatrix[i]=relationsss;
								//relationMatrix[j][i]=relationsss;
							
							}
							else 
							{
								relationMatrix[i]=0.0;
								//relationMatrix[j][i]=0.0;
								
							}
//		  			
						
					}
		  		System.out.println("thread 7 done");
			}
		}
			public  class Thread18 extends Thread {
				LinkedHashMap<ArrayList<Integer>,Integer> linkfrequency;
				int[][] data_matrix;
				double[] makhraj;
				Map index;
				ArrayList<String> documentTerms;
				public Thread18(LinkedHashMap<ArrayList<Integer>,Integer> linkfrequency2,int[][]data_matrix,double[] makhraj,Map index,ArrayList<String>documentTerms)
				{
					this.linkfrequency=linkfrequency2;
					this.data_matrix=data_matrix;
					this.makhraj=makhraj;
					this.index=index;
					this.documentTerms=documentTerms;
			
				}
				@Override
				public void run()
				{
					int start=(7*(linkfrequency.size()/8))+1;
					int end	= linkfrequency.size();
		  		 for (int i=start;i<end;++i)
		  		{
//		  			 if (linkfrequency[i][2]>=Main.linkFrequnecyParameter)
//		  			 {
			  			Set<ArrayList<Integer>> keys = linkfrequency.keySet();
		  			 	Object[] keyarray = keys.toArray();
		  			 	ArrayList<Integer> x =(ArrayList<Integer>) keyarray[i];
		  			 	
		  			 	int term_i_int = x.get(0);
		  			 	int term_j_int = x.get(1);
		  			 	
		  				double makhraj_i=makhraj[term_i_int];
		  				double makhraj_j=makhraj[term_j_int];
		  				
		  				InvertedIndex object=new InvertedIndex();
		  				
		  				String term_i = documentTerms.get(term_i_int);
		  				String term_j = documentTerms.get(term_j_int);
		  				
		  				Set Set_i = object.search(term_i,index);
		  				Set Set_j = object.search(term_j,index);
		  				
			  			double soorat=soorat(Set_i,Set_j);
						double relationsss=Double.parseDouble((df.format((Math.max(((double)soorat/makhraj_i),(double)soorat/makhraj_j)))));
						if (relationsss>=Main.link_relation)
							{
								relationMatrix[i]=relationsss;
								//relationMatrix[j][i]=relationsss;
							
							}
							else 
							{
								relationMatrix[i]=0.0;
								//relationMatrix[j][i]=0.0;
								
							}
//		  			
						
					}
		  		System.out.println("thread 8 done");
			}
		}
			public  class Thread21 extends Thread {
							
							public void run()
							{
								int end = (unioned.size()) / 8;
								for (int i1=0;i1<=end;++i1)
									{
										ArrayList<Double> current=new ArrayList<Double>();
										String termRow=unioned.get(i1);
										int termRowIndex=documentTerms.indexOf(termRow);
									//	int termRowIndexInSemGraph=Main.semanticTerm.indexOf(termRow);
									//	int termRowIndexInCoGraph=Main.coTerms.indexOf(termRow);
										for (int j=0;j<unioned.size();++j)
										{
											String termCol=unioned.get(j);
											int termColIndex=documentTerms.indexOf(termCol);
											if(termRowIndex==termColIndex)
											{
												current.add(1.0);
												continue;
											}
											//\\int termColIndexInSemGraph=Main.semanticTerm.indexOf(termCol);
											//\\int termColIndexInCoGraph=Main.coTerms.indexOf(termCol);
											
											//int termColIndexInCoGraph=Main.coTerms.indexOf(termCol);
											double CoGraphRelation=0.0;
											double semanticRelation=0.0;
											
											try
											{
												// CoGraphRelation=relationMatrix[]
											}
											catch(Exception e)
											{
												CoGraphRelation=0;
											}
											
											try
											{
												//\\semanticRelation=Main.SemanticGraph.get(termRow).get(termColIndexInSemGraph);
											}
											catch(Exception e)
											{
												semanticRelation=0;
											}
											
											int situation=0;
//											if (termColIndexInCoGraph!=(-1)&termRowIndexInCoGraph!=(-1) & CoGraphRelation!=0)
//												situation=1;
//											else if (termColIndexInSemGraph!=(-1)&termRowIndexInSemGraph!=(-1)& semanticRelation!=0)
//												situation=2;
//											else
//												situation=3;
											if (CoGraphRelation>0)
												situation=1;
											else if (semanticRelation>0)
												situation=2;
											else
												situation=3;
											
											
											switch(situation)
											{
											case 1:
												current.add(CoGraphRelation);
												break;
											case 2:
												double pti=Collections.max(Main.termTopicMap.get(termCol));
												double ptj=Collections.max(Main.termTopicMap.get(termRow));
												double rSem=Double.parseDouble(dfForSemanticRelation.format((Math.sqrt(pti*ptj))*(Math.exp((Math.abs(pti-ptj)*(-1))/Math.max(pti, ptj)))));
												current.add(rSem);
												break;
												
											case 3:
												current.add(0.0);
												
											}
											
									
											
										
										}
									
										merged.put(unioned.get(i1), current);
										//System.out.println("done");
										if (i1%500==0)
										System.out.println("merging "+i1+" of "+end+ " done");
									}
								System.out.println("Thread1 done.");
							}
					}
			public  class Thread22 extends Thread {
				
				public void run()
				{
					int start=((unioned.size()) / 8)+1;
					int end = (unioned.size()) / 4;
					for (int i1=start;i1<=end;++i1)
						{
							ArrayList<Double> current=new ArrayList<Double>();
							String termRow=unioned.get(i1);
							//int termRowIndexInSemGraph=Main.semanticTerm.indexOf(termRow);
							//int termRowIndexInCoGraph=Main.coTerms.indexOf(termRow);
							for (int j=0;j<unioned.size();++j)
							{
								String termCol=unioned.get(j);
								if(termRow==termCol)
								{
									current.add(1.0);
									continue;
								}
								int termColIndexInSemGraph=Main.semanticTerm.indexOf(termCol);
							//\\int termColIndexInCoGraph=Main.coTerms.indexOf(termCol);
								double CoGraphRelation=0.0;
								double semanticRelation=0.0;
								//double SemanticRelation=0.0;
								try
								{
									//\\ CoGraphRelation=Main.CoGraphMap.get(termRow).get(termColIndexInCoGraph);
								}
								catch(Exception e)
								{
									//nothing
								}
								
								try
								{
									semanticRelation=Main.SemanticGraph.get(termRow).get(termColIndexInSemGraph);
								}
								catch(Exception e)
								{
									//nothing
								}
								
								int situation=0;
//								if (termColIndexInCoGraph!=(-1)&termRowIndexInCoGraph!=(-1) & CoGraphRelation!=0)
//									situation=1;
//								else if (termColIndexInSemGraph!=(-1)&termRowIndexInSemGraph!=(-1)& semanticRelation!=0)
//									situation=2;
//								else
//									situation=3;
								if (CoGraphRelation>0)
									situation=1;
								else if (semanticRelation>0)
									situation=2;
								else
									situation=3;
							
								
								switch(situation)
								{
								case 1:
									current.add(CoGraphRelation);
									break;
								case 2:
									double pti=Collections.max(Main.termTopicMap.get(termCol));
									double ptj=Collections.max(Main.termTopicMap.get(termRow));
									double rSem=Double.parseDouble(dfForSemanticRelation.format((Math.sqrt(pti*ptj))*(Math.exp((Math.abs(pti-ptj)*(-1))/Math.max(pti, ptj)))));
									current.add(rSem);
									break;
									
								case 3:
									current.add(0.0);
									
								}
								
						
								
							
							}
						
							merged.put(unioned.get(i1), current);
							//System.out.println("done");
						
						}
					System.out.println("Thread2 done.");
				}
			}
			public  class Thread23 extends Thread {
				
				public void run()
				{
					int start=((unioned.size()) / 4)+1;
					int end = (3*(unioned.size()) / 8);
					for (int i1=start;i1<=end;++i1)
						{
							ArrayList<Double> current=new ArrayList<Double>();
							String termRow=unioned.get(i1);
							//int termRowIndexInSemGraph=Main.semanticTerm.indexOf(termRow);
							//int termRowIndexInCoGraph=Main.coTerms.indexOf(termRow);
							for (int j=0;j<unioned.size();++j)
							{
								String termCol=unioned.get(j);
								if(termRow==termCol)
								{
									current.add(1.0);
									continue;
								}
								int termColIndexInSemGraph=Main.semanticTerm.indexOf(termCol);
								//\\int termColIndexInCoGraph=Main.coTerms.indexOf(termCol);
								double CoGraphRelation=0.0;
								double semanticRelation=0.0;
								//double SemanticRelation=0.0;
								try
								{
									//\\ CoGraphRelation=Main.CoGraphMap.get(termRow).get(termColIndexInCoGraph);
								}
								catch(Exception e)
								{
									//nothing
								}
								
								try
								{
									semanticRelation=Main.SemanticGraph.get(termRow).get(termColIndexInSemGraph);
								}
								catch(Exception e)
								{
									//nothing
								}
								
								int situation=0;
//								if (termColIndexInCoGraph!=(-1)&termRowIndexInCoGraph!=(-1) & CoGraphRelation!=0)
//									situation=1;
//								else if (termColIndexInSemGraph!=(-1)&termRowIndexInSemGraph!=(-1)& semanticRelation!=0)
//									situation=2;
//								else
//									situation=3;
								if (CoGraphRelation>0)
									situation=1;
								else if (semanticRelation>0)
									situation=2;
								else
									situation=3;
								
								switch(situation)
								{
								case 1:
									current.add(CoGraphRelation);
									break;
								case 2:
									double pti=Collections.max(Main.termTopicMap.get(termCol));
									double ptj=Collections.max(Main.termTopicMap.get(termRow));
									double rSem=Double.parseDouble(dfForSemanticRelation.format((Math.sqrt(pti*ptj))*(Math.exp((Math.abs(pti-ptj)*(-1))/Math.max(pti, ptj)))));
									current.add(rSem);
									break;
									
								case 3:
									current.add(0.0);
									
								}
								
						
								
							
							}
						
							merged.put(unioned.get(i1), current);
							//System.out.println("done");
							
						}
					System.out.println("Thread3 done.");
				}
			}
			public  class Thread24 extends Thread {
				
				public void run()
				{
					int start=(3*(unioned.size()) / 8)+1;
					int end = (unioned.size()) / 2;
					for (int i1=start;i1<=end;++i1)
						{
							ArrayList<Double> current=new ArrayList<Double>();
							String termRow=unioned.get(i1);
						//	int termRowIndexInSemGraph=Main.semanticTerm.indexOf(termRow);
						//	int termRowIndexInCoGraph=Main.coTerms.indexOf(termRow);
							for (int j=0;j<unioned.size();++j)
							{
								String termCol=unioned.get(j);
								if(termRow==termCol)
								{
									current.add(1.0);
									continue;
								}
								int termColIndexInSemGraph=Main.semanticTerm.indexOf(termCol);
								//\\int termColIndexInCoGraph=Main.coTerms.indexOf(termCol);
								double CoGraphRelation=0.0;
								double semanticRelation=0.0;
								//double SemanticRelation=0.0;
								try
								{
									//\\ CoGraphRelation=Main.CoGraphMap.get(termRow).get(termColIndexInCoGraph);
								}
								catch(Exception e)
								{
									//nothing
								}
								
								try
								{
									semanticRelation=Main.SemanticGraph.get(termRow).get(termColIndexInSemGraph);
								}
								catch(Exception e)
								{
									//nothing
								}
								
								int situation=0;
//								if (termColIndexInCoGraph!=(-1)&termRowIndexInCoGraph!=(-1) & CoGraphRelation!=0)
//									situation=1;
//								else if (termColIndexInSemGraph!=(-1)&termRowIndexInSemGraph!=(-1)& semanticRelation!=0)
//									situation=2;
//								else
//									situation=3;
								if (CoGraphRelation>0)
									situation=1;
								else if (semanticRelation>0)
									situation=2;
								else
									situation=3;
								
								switch(situation)
								{
								case 1:
									current.add(CoGraphRelation);
									break;
								case 2:
									double pti=Collections.max(Main.termTopicMap.get(termCol));
									double ptj=Collections.max(Main.termTopicMap.get(termRow));
									double rSem=Double.parseDouble(dfForSemanticRelation.format((Math.sqrt(pti*ptj))*(Math.exp((Math.abs(pti-ptj)*(-1))/Math.max(pti, ptj)))));
									current.add(rSem);
									break;
									
								case 3:
									current.add(0.0);
									
								}
								
						
								
							
							}
						
							merged.put(unioned.get(i1), current);
							//System.out.println("done");
						
						}
					System.out.println("Thread4 done.");
				}
			}
			public  class Thread25 extends Thread {
				
				public void run()
				{
					int start=((unioned.size()) / 2)+1;
					int end = (5*(unioned.size()) / 8);
					for (int i1=start;i1<=end;++i1)
						{
							ArrayList<Double> current=new ArrayList<Double>();
							String termRow=unioned.get(i1);
						//	int termRowIndexInSemGraph=Main.semanticTerm.indexOf(termRow);
						//	int termRowIndexInCoGraph=Main.coTerms.indexOf(termRow);
							for (int j=0;j<unioned.size();++j)
							{
								String termCol=unioned.get(j);
								if(termRow==termCol)
								{
									current.add(1.0);
									continue;
								}
								int termColIndexInSemGraph=Main.semanticTerm.indexOf(termCol);
								//\\int termColIndexInCoGraph=Main.coTerms.indexOf(termCol);
								double CoGraphRelation=0.0;
								double semanticRelation=0.0;
								//double SemanticRelation=0.0;
								try
								{
									//\\ CoGraphRelation=Main.CoGraphMap.get(termRow).get(termColIndexInCoGraph);
								}
								catch(Exception e)
								{
									//nothing
								}
								
								try
								{
									semanticRelation=Main.SemanticGraph.get(termRow).get(termColIndexInSemGraph);
								}
								catch(Exception e)
								{
									//nothing
								}
								
								int situation=0;
//								if (termColIndexInCoGraph!=(-1)&termRowIndexInCoGraph!=(-1) & CoGraphRelation!=0)
//									situation=1;
//								else if (termColIndexInSemGraph!=(-1)&termRowIndexInSemGraph!=(-1)& semanticRelation!=0)
//									situation=2;
//								else
//									situation=3;
								if (CoGraphRelation>0)
									situation=1;
								else if (semanticRelation>0)
									situation=2;
								else
									situation=3;
								
								switch(situation)
								{
								case 1:
									current.add(CoGraphRelation);
									break;
								case 2:
									double pti=Collections.max(Main.termTopicMap.get(termCol));
									double ptj=Collections.max(Main.termTopicMap.get(termRow));
									double rSem=Double.parseDouble(dfForSemanticRelation.format((Math.sqrt(pti*ptj))*(Math.exp((Math.abs(pti-ptj)*(-1))/Math.max(pti, ptj)))));
									current.add(rSem);
									break;
									
								case 3:
									current.add(0.0);
									
								}
								
						
								
							
							}
						
							merged.put(unioned.get(i1), current);
							//System.out.println("done");
							
						}
					System.out.println("Thread5 done.");
				}
			}
			public  class Thread26 extends Thread {
				
				public void run()
				{
					int start=(5*(unioned.size()) / 8)+1;
					int end = (3*(unioned.size())) / 4;
					for (int i1=start;i1<=end;++i1)
						{
							ArrayList<Double> current=new ArrayList<Double>();
							String termRow=unioned.get(i1);
						//	int termRowIndexInSemGraph=Main.semanticTerm.indexOf(termRow);
						//	int termRowIndexInCoGraph=Main.coTerms.indexOf(termRow);
							for (int j=0;j<unioned.size();++j)
							{
								String termCol=unioned.get(j);
								if(termRow==termCol)
								{
									current.add(1.0);
									continue;
								}
								int termColIndexInSemGraph=Main.semanticTerm.indexOf(termCol);
							//\\	int termColIndexInCoGraph=Main.coTerms.indexOf(termCol);
								double CoGraphRelation=0.0;
								double semanticRelation=0.0;
								//double SemanticRelation=0.0;
								try
								{
									//\\ CoGraphRelation=Main.CoGraphMap.get(termRow).get(termColIndexInCoGraph);
								}
								catch(Exception e)
								{
									//nothing
								}
								
								try
								{
									semanticRelation=Main.SemanticGraph.get(termRow).get(termColIndexInSemGraph);
								}
								catch(Exception e)
								{
									//nothing
								}
								
								int situation=0;
//								if (termColIndexInCoGraph!=(-1)&termRowIndexInCoGraph!=(-1) & CoGraphRelation!=0)
//									situation=1;
//								else if (termColIndexInSemGraph!=(-1)&termRowIndexInSemGraph!=(-1)& semanticRelation!=0)
//									situation=2;
//								else
//									situation=3;
								if (CoGraphRelation>0)
									situation=1;
								else if (semanticRelation>0)
									situation=2;
								else
									situation=3;
								
								switch(situation)
								{
								case 1:
									current.add(CoGraphRelation);
									break;
								case 2:
									double pti=Collections.max(Main.termTopicMap.get(termCol));
									double ptj=Collections.max(Main.termTopicMap.get(termRow));
									double rSem=Double.parseDouble(dfForSemanticRelation.format((Math.sqrt(pti*ptj))*(Math.exp((Math.abs(pti-ptj)*(-1))/Math.max(pti, ptj)))));
									current.add(rSem);
									break;
									
								case 3:
									current.add(0.0);
									
								}
								
						
								
							
							}
						
							merged.put(unioned.get(i1), current);
							//System.out.println("done");
						
						}
					System.out.println("Thread6 done.");
				}
			}
			public  class Thread27 extends Thread {
				
				public void run()
				{
					int start=(3*(unioned.size()) / 4)+1;
					int end = (7*(unioned.size())) / 8;
					for (int i1=start;i1<=end;++i1)
						{
							ArrayList<Double> current=new ArrayList<Double>();
							String termRow=unioned.get(i1);
							//int termRowIndexInSemGraph=Main.semanticTerm.indexOf(termRow);
							//int termRowIndexInCoGraph=Main.coTerms.indexOf(termRow);
							for (int j=0;j<unioned.size();++j)
							{
								String termCol=unioned.get(j);
								if(termRow==termCol)
								{
									current.add(1.0);
									continue;
								}
								int termColIndexInSemGraph=Main.semanticTerm.indexOf(termCol);
								//\\int termColIndexInCoGraph=Main.coTerms.indexOf(termCol);
								double CoGraphRelation=0.0;
								double semanticRelation=0.0;
								//double SemanticRelation=0.0;
								try
								{
									//\\ CoGraphRelation=Main.CoGraphMap.get(termRow).get(termColIndexInCoGraph);
								}
								catch(Exception e)
								{
									//nothing
								}
								
								try
								{
									semanticRelation=Main.SemanticGraph.get(termRow).get(termColIndexInSemGraph);
								}
								catch(Exception e)
								{
									//nothing
								}
								
								int situation=0;
//								if (termColIndexInCoGraph!=(-1)&termRowIndexInCoGraph!=(-1) & CoGraphRelation!=0)
//									situation=1;
//								else if (termColIndexInSemGraph!=(-1)&termRowIndexInSemGraph!=(-1)& semanticRelation!=0)
//									situation=2;
//								else
//									situation=3;
								if (CoGraphRelation>0)
									situation=1;
								else if (semanticRelation>0)
									situation=2;
								else
									situation=3;
								
								switch(situation)
								{
								case 1:
									current.add(CoGraphRelation);
									break;
								case 2:
									double pti=Collections.max(Main.termTopicMap.get(termCol));
									double ptj=Collections.max(Main.termTopicMap.get(termRow));
									double rSem=Double.parseDouble(dfForSemanticRelation.format((Math.sqrt(pti*ptj))*(Math.exp((Math.abs(pti-ptj)*(-1))/Math.max(pti, ptj)))));
									current.add(rSem);
									break;
									
								case 3:
									current.add(0.0);
									
								}
								
						
								
							
							}
						
							merged.put(unioned.get(i1), current);
							//System.out.println("done");
						
						}
					System.out.println("Thread7 done.");
				}
			}
			public  class Thread28 extends Thread {
				
				public void run()
				{
					int start=(7*(unioned.size()) / 8)+1;
					int end = (unioned.size());
					for (int i1=start;i1<end;++i1)
						{
							ArrayList<Double> current=new ArrayList<Double>();
							String termRow=unioned.get(i1);
						//	int termRowIndexInSemGraph=Main.semanticTerm.indexOf(termRow);
						//	int termRowIndexInCoGraph=Main.coTerms.indexOf(termRow);
							for (int j=0;j<unioned.size();++j)
							{
								String termCol=unioned.get(j);
								if(termRow==termCol)
								{
									current.add(1.0);
									continue;
								}
								int termColIndexInSemGraph=Main.semanticTerm.indexOf(termCol);
								//\\int termColIndexInCoGraph=Main.coTerms.indexOf(termCol);
								double CoGraphRelation=0.0;
								double semanticRelation=0.0;
								//double SemanticRelation=0.0;
								try
								{
									//\\CoGraphRelation=Main.CoGraphMap.get(termRow).get(termColIndexInCoGraph);
								}
								catch(Exception e)
								{
									//nothing
								}
								
								try
								{
									semanticRelation=Main.SemanticGraph.get(termRow).get(termColIndexInSemGraph);
								}
								catch(Exception e)
								{
									//nothing
								}
								
								int situation=0;
//								if (termColIndexInCoGraph!=(-1)&termRowIndexInCoGraph!=(-1) & CoGraphRelation!=0)
//									situation=1;
//								else if (termColIndexInSemGraph!=(-1)&termRowIndexInSemGraph!=(-1)& semanticRelation!=0)
//									situation=2;
//								else
//									situation=3;
								if (CoGraphRelation>0)
									situation=1;
								else if (semanticRelation>0)
									situation=2;
								else
									situation=3;
								
								switch(situation)
								{
								case 1:
									current.add(CoGraphRelation);
									break;
								case 2:
									double pti=Collections.max(Main.termTopicMap.get(termCol));
									double ptj=Collections.max(Main.termTopicMap.get(termRow));
									double rSem=Double.parseDouble(dfForSemanticRelation.format((Math.sqrt(pti*ptj))*(Math.exp((Math.abs(pti-ptj)*(-1))/Math.max(pti, ptj)))));
									current.add(rSem);
									break;
									
								case 3:
									current.add(0.0);
									
								}
								
						
								
							
							}
						
							merged.put(unioned.get(i1), current);
							//System.out.println("done");
							
						}
					
						System.out.println("Thread8 done.");
				}
			}
						
			
			
	  	
	  	public  double [] relation(String filename,LinkedHashMap<ArrayList<Integer>,Integer> linkfrequency,String datasetName,ArrayList<String> documentTerms) throws  Exception

	  	{
	  		docTermSize=documentTerms.size();
	  		relationMatrix=new double [linkfrequency.size()];
	  		 data_matrix = Main.dataMatricExtractor(docTermSize,filename);
	  		 makhraj=new double [docTermSize];
	  		// flag= new boolean [docTermSize];
	  		System.out.println("........");
	  		InvertedIndex object=new InvertedIndex();
	  		//index=;
	  		Map index = object.mainMethod(datasetName);
	  		for (int i=0;i<docTermSize;++i)
	  		{
	  			Set result = object.search(documentTerms.get(i),index);
	  			double sum=0;
	  			Integer[] arr = (Integer[]) result.toArray(new Integer[result.size()]);
	  			for (int j=0;j<result.size();++j)
	  			{
	  				sum=sum+((double)1/capacity[arr[j]]);
	  			}
	  			
	  			makhraj[i]=sum;
	  		
	  		}
	  		
	  		Thread11 t11=new Thread11(linkfrequency,data_matrix,makhraj,index,documentTerms);  
	  		Thread12 t12=new Thread12(linkfrequency,data_matrix,makhraj,index,documentTerms);
			Thread13 t13=new Thread13(linkfrequency,data_matrix,makhraj,index,documentTerms);
			Thread14 t14=new Thread14(linkfrequency,data_matrix,makhraj,index,documentTerms);
			Thread15 t15=new Thread15(linkfrequency,data_matrix,makhraj,index,documentTerms);
			Thread16 t16=new Thread16(linkfrequency,data_matrix,makhraj,index,documentTerms);
			Thread17 t17=new Thread17(linkfrequency,data_matrix,makhraj,index,documentTerms);
			Thread18 t18=new Thread18(linkfrequency,data_matrix,makhraj,index,documentTerms);
			
			
		t11.start();
		t12.start();
		t13.start();
		t14.start();
		t15.start();
		t16.start();
		t17.start();
		t18.start();
		
		t11.join();
		t12.join();
		t13.join();
		t14.join();
		t15.join();
		t16.join();
		t17.join();
		t18.join();
		
			   
	  		return relationMatrix;
	  		
	  	}
		public  HashMap<String, ArrayList<Double>> merging() throws Exception
		{
			merged=new HashMap <String,ArrayList<Double>>(Main.unioned.size());
			unioned=Main.unioned;
			//coTerms=coTerms;
			
			Thread21 t21=new Thread21();  
	  		Thread22 t22=new Thread22();
			Thread23 t23=new Thread23();
			Thread24 t24=new Thread24();
			Thread25 t25=new Thread25();
			Thread26 t26=new Thread26();
			Thread27 t27=new Thread27();
			Thread28 t28=new Thread28();
			
			
		t21.start();
		t22.start();
		t23.start();
		t24.start();
		t25.start();
		t26.start();
		t27.start();
		t28.start();
		
		t21.join();
		t22.join();
		t23.join();
		t24.join();
		t25.join();
		t26.join();
		t27.join();
		t28.join();
			return merged;
			
		}

		public  double soorat(Set A,Set B) {
			
			double sum=0;
			//A.remove(A.size()-1);
			//B.remove(B.size()-1);
			A.retainAll(B);
			Integer[] arr = (Integer[]) A.toArray(new Integer[A.size()]);
			for (int i=0;i<A.size();++i)
			{
				sum=sum+((double)1/capacity[arr[i]]);
			}
			
			return sum;
		}

//		public  ArrayList<Integer> makhraj(int i) {
//			
//			if (flag[i]==false)
//			{
//			int sum=0;
//			ArrayList<Integer> makhraj = new ArrayList<Integer>();
//			int datamatrixLenght=data_matrix.length;
//			for (int ii=0;ii<datamatrixLenght;++ii)
//			{
//				
//				if((data_matrix[ii][1]==i))
//				{
//					sum=sum+Main.capacity[(data_matrix[ii][0])];
//					makhraj.add((data_matrix[ii][0]));
//					
//				}
//				
//			}
//			makhraj.add(sum);
//			memory.put(i, makhraj);
//			flag[i]=true;
//
//			//makhraj_i=sum;
//			
//			
//			return makhraj;
//			
//			}
//			else
//			{return memory.get(i); }//somethings}
//		}
	}

