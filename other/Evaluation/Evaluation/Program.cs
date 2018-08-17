using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
// bayad unique match beshe. alan shayad!!! unique match nist. unique match and best match
//albatte felan donbale best match nistim. choon T==C.(Truth==Cluster)
namespace Evaluation
{
    class Program
    {
        struct cMeasure
        {
            public int Count;
            public double Pre;
            public double Rec;
            public double F;
        };
        static void Main(string[] args)
        {
            //khandan etelaat marboot be file result
            Console.Write("Enter document number:");

            int n = Convert.ToInt32(Console.ReadLine());//tedad kol sanadha
            int docNum = 0;

            string fileName = System.IO.Path.GetFullPath(Directory.GetCurrentDirectory() + "\\Result.txt");
            System.IO.StreamReader resultFile =
           new System.IO.StreamReader(fileName);

            int lineCounter = 0;
            string Line;


            Dictionary<int, string> docIDof = new Dictionary<int, string>();
            Dictionary<string, int> numOf = new Dictionary<string, int>();

            Dictionary<int, int[]> myClusters = new Dictionary<int, int[]>();



            //----------------



            while ((Line = resultFile.ReadLine()) != null)
            {

                string[] LineData = new string[n];
                char[] lineChar = Line.ToCharArray();
                int WordCounter = 0;
                string word = "";

                for (int i = 0; i < lineChar.Length; i++)
                {
                    if (lineChar[i] == ' ')
                    {
                        if (word != "")
                        {
                            LineData[WordCounter] = word;
                            WordCounter++;
                            word = "";
                        }
                    }
                    else
                    {
                        word += Convert.ToString(lineChar[i]);
                    }
                }
                if (word != "")
                {
                    LineData[WordCounter] = word;
                    WordCounter++;
                    word = "";
                }


                myClusters[lineCounter] = new int[WordCounter];

                for (int cw = 0; cw < WordCounter; cw++)
                {
                    if (numOf.ContainsKey(LineData[cw]))
                    {
                        myClusters[lineCounter][cw] = numOf[LineData[cw]];
                    }
                    else
                    {
                        numOf[LineData[cw]] = docNum;
                        docIDof[docNum] = LineData[cw];
                        myClusters[lineCounter][cw] = docNum;
                        docNum++;
                    }
                }



                lineCounter++;
            }
            int myClusterNO = lineCounter;
            int totalDoc = docNum;





            //khandan etelaat marboot be file judgment

            string fileName2 = System.IO.Path.GetFullPath(Directory.GetCurrentDirectory() + "\\judgment.txt");
            System.IO.StreamReader file =
           new System.IO.StreamReader(fileName2);




            Dictionary<int, int[]> realClusters = new Dictionary<int, int[]>();


            lineCounter = 0;
            Line = "";
            //----------------

            int temp = 0;

            while ((Line = file.ReadLine()) != null)
            {

                string[] LineData = new string[n];
                char[] lineChar = Line.ToCharArray();
                int WordCounter = 0;
                string word = "";

                for (int i = 0; i < lineChar.Length; i++)
                {
                    if (lineChar[i] == ' ')
                    {
                        if (word != "")
                        {
                            LineData[WordCounter] = word;
                            WordCounter++;
                            word = "";
                        }
                    }
                    else
                    {
                        word += Convert.ToString(lineChar[i]);
                    }
                }
                if (word != "")
                {
                    LineData[WordCounter] = word;
                    WordCounter++;
                    word = "";
                }


                realClusters[lineCounter] = new int[WordCounter];
                int dCount = 0;
                for (int cw = 0; cw < WordCounter; cw++)
                {

                    if (numOf.ContainsKey(LineData[cw]))
                    {
                        realClusters[lineCounter][dCount] = numOf[LineData[cw]];
                        dCount++;
                    }
                    else
                    {
                        temp++;
                        //    numOf[LineData[cw]] = docNum;
                        //    docIDof[docNum] = LineData[cw];
                        //    realClusters[lineCounter][cw] = docNum;
                        //    docNum++;
                    }
                }



                lineCounter++;
            }
            int realClusterNO = lineCounter;







          //  int[] myclusters0 = myClusters[0];
          //  int[] myclusters1 = myClusters[1];
          ////  int[] myclusters2 = myClusters[2];
          //  int[] realclusters0 = realClusters[0];
          //  int[] realclusters1 = realClusters[1];
          //  int[] realcluster2 = realClusters[2];
            //------------------------------------

            //shoroo be arzyabi

            Dictionary<int, cMeasure> ClusterM = new Dictionary<int, cMeasure>();
            int i2 = 0;
            for (int mc = 0; mc < myClusterNO; mc++)
            {
                cMeasure clM;
                double maxPre = 0;
                double maxRec = 0;
                double maxF = 0;
                for (int cs = 0; cs < realClusterNO; cs++)
                {
                    var IntArr = realClusters[cs].Intersect(myClusters[mc]).ToArray();
                   // var IntArr2 = myClusters[mc].Intersect(realClusters[cs]).ToArray();
                    double myPre = Convert.ToDouble(IntArr.Length) / Convert.ToDouble(myClusters[mc].Length);
                   double myRec = Convert.ToDouble(IntArr.Length) / Convert.ToDouble(realClusters[cs].Length);
                   ++i2;
                   // double myPre = Convert.ToDouble(IntArr.Length) / Convert.ToDouble(realClusters[cs].Length);
                   // double myRec = Convert.ToDouble(IntArr.Length) / Convert.ToDouble(myClusters[mc].Length);


                    double myF = (2*myPre * myRec) / ( (myRec + myPre));
                    if (myF > maxF)
                    {
                        maxF = myF;
                        maxPre = myPre;
                        maxRec = myRec;
                    }
                }
                clM.Count = realClusters[mc].Length;
                clM.Pre = maxPre;
                clM.Rec = maxRec;
                clM.F = maxF;
                ClusterM[mc] = clM;


            }
            Console.WriteLine(i2);

            //mohasebe mianginha
            double totalPrecision = 0;
            double totalRecall = 0;
            double totalFvalue = 0;

            for (int rc = 0; rc < myClusterNO; rc++)
            {

                totalPrecision = totalPrecision + ClusterM[rc].Pre;
                totalRecall = totalRecall + ClusterM[rc].Rec;
                totalFvalue = totalFvalue + ClusterM[rc].F;

               // totalPrecision = totalPrecision + ((Convert.ToDouble(ClusterM[rc].Count) / Convert.ToDouble(totalDoc)) * ClusterM[rc].Pre);
               // totalRecall = totalRecall + ((Convert.ToDouble(ClusterM[rc].Count) / Convert.ToDouble(totalDoc)) * ClusterM[rc].Rec);
               // totalFvalue = (totalPrecision * totalRecall) / (0.5 * (totalRecall + totalPrecision));
            }
          
            totalPrecision = totalPrecision / realClusterNO;
            totalFvalue = totalFvalue / realClusterNO;
            totalRecall = totalRecall / realClusterNO;

          //  Console.WriteLine("Precision  -------->        " + Convert.ToString(totalPrecision));
         //   Console.WriteLine("Recall     -------->        " + Convert.ToString(totalRecall));
         //   Console.WriteLine("F-value    -------->        " + Convert.ToString(totalFvalue));
            Console.WriteLine("Precision  -------->        " + totalPrecision);
            Console.WriteLine("Recall     -------->        " + totalRecall);
            Console.WriteLine("F-value    -------->        " + totalFvalue);
            Console.ReadLine();
        }
    }
}
