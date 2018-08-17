package commentFecherDB;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

public class nullCommentRemover {
	public static void main(String[] args) throws IOException {
//		cleanOutput();
//		removeDup();
	}
	public static void cleanOutput() throws IOException {

		BufferedReader br = new BufferedReader(new FileReader(new File("output/stage1NoRES.txt")));
		BufferedWriter bw = new BufferedWriter(new FileWriter(new File("output/stage2NoNull.txt")));
		String line;
		while ((line = br.readLine()) != null) {
			String[] splitedLine = line.split("\t");
			if (splitedLine.length>3) {
				bw.write(line);
				bw.newLine();
			}
		}
		br.close();
		bw.close();
		System.out.println("output null line cleaned!");
	}
	
	public static void removeDup() throws IOException {

		int counter= 0;
		BufferedReader br = new BufferedReader( new InputStreamReader(new FileInputStream("output/stage2NoNull.txt"), "UTF8"));
		BufferedWriter bw = new BufferedWriter(new FileWriter(new File("output/stage3NoDup.txt")));
		ArrayList<String> allLinesContent=new ArrayList<String>();
		ArrayList<String> allLinesAll=new ArrayList<String>();
		String line;
		while ((line = br.readLine()) != null) {
		
			String[] splitedline = line.split("\t");
			allLinesContent.add(splitedline[3]);
			allLinesAll.add(line);
		}
		br.close();
		for (int i = 0; i <allLinesContent.size()-1; ++i) {
				if (!(allLinesContent.get(i).equals(allLinesContent.get(i+1))))
				{
					String line2 = allLinesAll.get(i);
					line2.replace("ی", "ي");
					bw.write(line2);
					bw.newLine();
				}
				else
				{
					++counter;
				}
					
			}

		System.out.println("output dup line cleaned! and counter = "+counter);
		bw.close();
	}

}
