import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class CommentFetcherFromDB {
	public static void main(String[] args) throws ClassNotFoundException, SQLException, IOException {
		Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
		Connection conn = DriverManager.getConnection(
				"jdbc:sqlserver://mostafa-vaio\\sqlserver;databaseName=ghatl_dadashi;integratedSecurity=true");
		PreparedStatement statement = conn.prepareStatement("select * from all_comments_real where idkhabar = ? and agency = ?");
		BufferedReader br = new BufferedReader(new FileReader(new File("OldNewPlain.txt")));
		BufferedWriter bw = new BufferedWriter(new FileWriter(new File ("comments.txt")));
		String currentLine;
		while ((currentLine = br.readLine())!=null)
		{
			String[] lineParts = currentLine.split("\t");
			statement.setString(1, lineParts[2]);//id
			statement.setString(2, lineParts[1]);//agency
			ResultSet result = statement.executeQuery();
			while(result.next())
			{
				String content = result.getString("contents");
				content = content.replace(System.getProperty("line.separator"), "").replace("\r", "");
				bw.write(lineParts[2]+"-"+lineParts[1]+"\t"+content);
				bw.newLine();
			}
			System.out.println(lineParts[2]+" done");
		}
		br.close();
		bw.close();
	}
}
