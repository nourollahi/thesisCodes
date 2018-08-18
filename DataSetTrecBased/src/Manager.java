import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Manager {
	public LinkedHashMap<String, String> readNeededID() throws Exception {
		Scanner scanner;
		LinkedHashMap<String, String> neededID = new LinkedHashMap<>();
		try {
			int docNum = 0;
			scanner = new Scanner(new File("agency-id-comment.txt"));
			while (scanner.hasNext()) {
				String[] line = scanner.nextLine().split("-");
				neededID.put(++docNum + "", line[0]+"-"+line[1]);
//				docNum++;
			}
			System.out.println("needed item count" + neededID.size());
			scanner.close();
			return neededID;
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return null;
		}
	}

	public static void main(String[] args) throws SQLException, IOException {
		Manager manager = new Manager();
		LinkedHashMap<String, String> ids;
		BufferedWriter bwDataset = new BufferedWriter(new FileWriter(new File("trecFormat.txt")));
//		BufferedWriter bwQuerySet = new BufferedWriter(new FileWriter(new File("query.txt")));
		try {
			bwDataset.write("<DOCS>\n");
			ids = manager.readNeededID();
			for (String row : ids.keySet()) {
				String[] id = ids.get(row).split("-");
				String content = DAO.getNewsFromDB(id[0],id[1]);//agency-id
				if (content != null) {
					//System.out.println(id[0]+"-"+id[1]);
					content = content.replaceAll("\\<.*?>", "");
					// write on Data set
					 bwDataset.write("<DOC>");
					 bwDataset.write("\n");
					 bwDataset.write("<DOCNO>");
					 bwDataset.write("doc_"+row+"_"+id[1]);
					 bwDataset.write("</DOCNO>");
					 bwDataset.write("\n");
					 bwDataset.write("<TEXT>");
					 bwDataset.write("\n");
					 bwDataset.write( content.replaceAll("\\<.*?>","").replaceAll("<div", "").replaceAll("&nbsp;", " "));
					 bwDataset.write("\n");
					 bwDataset.write("</TEXT>");
					 bwDataset.write("\n");
					 bwDataset.write("</DOC>\n");
					// segmentation
//					String regex = "(\\n|^).*?(?=\\n|$)";
//					Pattern pattern = Pattern.compile(regex);
//					Matcher matcher = pattern.matcher(content);
//					int segmentCounter = 1;
//					while (matcher.find()) {
//						System.out.println("doc number "+row);
//						
//						String queryString = matcher.group(0).replaceAll("\n", "");
//						if(queryString.length()>50)
//						{
//							bwQuerySet.write("<DOC query_"+row+"_"+segmentCounter+++">"+"\n");
//							bwQuerySet.write(queryString+"\n");
//							bwQuerySet.write("</DOC>"+"\n");
//						}
//						
						// for (int i = 1; i <= matcher.groupCount(); i++) {
						// System.out.println("Group " + i + ": " +
						// matcher.group(i));
						// }
					}
					// String[] segments = content.split(regex);
					//System.out.println("=======================");
				}

//			}
			bwDataset.write("</DOCS>");
			bwDataset.close();
//			bwQuerySet.close();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

}
