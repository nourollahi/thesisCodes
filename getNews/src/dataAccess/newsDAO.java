package dataAccess;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Arrays;
import java.util.HashMap;

import javax.print.attribute.standard.PrinterIsAcceptingJobs;

import fetcher.FetchNews;
import parser.ParseNews;

public class newsDAO {
	public static String printContent(String url, String source) {
		String htmlContent  = "";
		try {
			htmlContent = FetchNews.fetch(url, source);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return ParseNews.parse(htmlContent, source, url);
	}

	public static void main(String[] args) throws FileNotFoundException, InterruptedException, Exception {
		 dbUpdateFromCSV();
//		System.out.println(printContent("http://www.khabaronline.ir/detail/162897", "khabaronline"));
	}

	private static void dbUpdateFromCSV() throws ClassNotFoundException, InterruptedException, SQLException {
		Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
		HashMap<String, String> urlAgency = new HashMap<>();
		String csvFile = "agency-id.csv";
		BufferedReader br = null;
		String line = "";
		String cvsSplitBy = ",";

		try {

			br = new BufferedReader(new FileReader(csvFile));
			// br.readLine();
			while ((line = br.readLine()) != null) {
				String[] agencyID = line.split(cvsSplitBy);
				if (agencyID[0].equals("khabaronline")) {
					urlAgency.put("http://www.khabaronline.ir/detail/" + agencyID[1], "khabaronline");
				}
				if (agencyID[0].equals("tabnak")) {
					urlAgency.put("http://www.tabnak.ir/fa/news/" + agencyID[1], "tabnak");
				}
			}

		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (br != null) {
				try {
					br.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		HashMap<String, String> id2News = new HashMap<>();
		int counter = 0;
		int length = urlAgency.size();
		for (String url : urlAgency.keySet()) {
			System.out.println(++counter + " of " + length + " done url = " + url);
			Thread.sleep(3000);
			String structuredContent = newsDAO.printContent(url, urlAgency.get(url));
			url = url.replaceAll("http://", "");
			String[] urlParts = url.split("/");
			id2News.put(urlParts[(urlParts.length) - 1] + "-" + urlAgency.get("http://" + url), structuredContent);
			// break;
		}

		Connection conn = DriverManager
				.getConnection("jdbc:sqlserver://mostafa-vaio\\sqlserver;databaseName=rigi;integratedSecurity=true");
		String updateTableSQL = "UPDATE khabar  SET my_content = ? WHERE id = ? and khabar_gozari = ?";
		PreparedStatement preparedStatement = conn.prepareStatement(updateTableSQL);

		for (String id : id2News.keySet()) {
			String[] idSplited = id.split("-");
			preparedStatement.setString(1, id2News.get(id));
			preparedStatement.setInt(2, Integer.parseInt(idSplited[0]));
			preparedStatement.setString(3, idSplited[1]);
			preparedStatement.addBatch();
		}
		int[] res = preparedStatement.executeBatch();
		System.out.println(Arrays.toString(res));
		preparedStatement.close();
		conn.close();
		System.out.println("done");
	}

}
