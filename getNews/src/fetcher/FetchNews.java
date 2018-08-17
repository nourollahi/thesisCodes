package fetcher;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.URL;
import java.util.zip.GZIPInputStream;
import org.apache.commons.io.IOUtils;

public class FetchNews {
	public static String fetch(String targetURL, String urlParameters) {
		HttpURLConnection connection = null;
		String theString ="";
		try {
			// Create connection
			URL url = new URL(targetURL);
			connection = (HttpURLConnection) url.openConnection();
			connection.setRequestMethod("GET");
			connection.setRequestProperty("Content-Type", "text/html");
			connection.setRequestProperty("Content-Encoding", "gzip");
			connection.setRequestProperty("Charset", "utf-8");
			connection.setRequestProperty("Content-Length", Integer.toString(urlParameters.getBytes().length));
			connection.setRequestProperty("Content-Language", "fa-IR");
			//connection.setInstanceFollowRedirects(true);
			connection.setUseCaches(false);
			if (urlParameters.equals("khabaronline"))
			{
			connection.setDoOutput(true);
			int status = connection.getResponseCode();
			if (status == HttpURLConnection.HTTP_MOVED_TEMP
					  || status == HttpURLConnection.HTTP_MOVED_PERM) {
					    String location = connection.getHeaderField("Location");
//					    System.out.println(location);
					    URL newUrl = new URL(location);
					    connection = (HttpURLConnection) newUrl.openConnection();
					   
					}
			// Send request
			}
			connection.setDoOutput(true);
			DataOutputStream wr = new DataOutputStream(connection.getOutputStream());
			wr.writeBytes(urlParameters);
			wr.close();
			try {
				InputStream decompressed = new GZIPInputStream(connection.getInputStream());
				StringWriter writer = new StringWriter();
				IOUtils.copy(decompressed, writer, "utf-8");
				theString = writer.toString();

			} catch (Exception e) {
				StringWriter writer = new StringWriter();
				IOUtils.copy(connection.getInputStream(), writer, "utf-8");
				theString = writer.toString();
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (connection != null) {
				connection.disconnect();
			}
		}
		return theString;
	}
	
	public static String fetch2(String targetURL, String urlParameters) throws IOException {
		URL url = new URL(targetURL);
		HttpURLConnection con = (HttpURLConnection) url.openConnection();
		con.setRequestMethod("GET");
		con.setConnectTimeout(50000);
		con.setReadTimeout(50000);
		con.setRequestProperty("Content-Type", "text/html");
//		con.setRequestProperty("Content-Encoding", "gzip");
//		con.setRequestProperty("Charset", "utf-8");
//		con.setRequestProperty("Content-Length", Integer.toString(urlParameters.getBytes().length));
//		con.setRequestProperty("Content-Language", " en-US");
//		con.setInstanceFollowRedirects(false);
		int status = con.getResponseCode();
		if (status == HttpURLConnection.HTTP_MOVED_TEMP
				  || status == HttpURLConnection.HTTP_MOVED_PERM) {
				    String location = con.getHeaderField("Location");
				    System.out.println(location);
				    URL newUrl = new URL(location);
				    con = (HttpURLConnection) newUrl.openConnection();
				}
		
		BufferedReader in = new BufferedReader(
				  new InputStreamReader(con.getInputStream()));
				String inputLine;
				StringBuffer content = new StringBuffer();
				while ((inputLine = in.readLine()) != null) {
				    content.append(inputLine);
				}
				in.close();
//		String content;
//		InputStream decompressed = new GZIPInputStream(con.getInputStream());
//		StringWriter writer = new StringWriter();
//		IOUtils.copy(decompressed, writer, "utf-8");
//		content = writer.toString();
				
		return content.toString();
	}
	
}
