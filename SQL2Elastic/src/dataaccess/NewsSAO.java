package dataaccess;

import static org.elasticsearch.index.query.QueryBuilders.queryStringQuery;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Scanner;
import org.elasticsearch.action.admin.cluster.health.ClusterHealthResponse;
import org.elasticsearch.action.admin.indices.delete.DeleteIndexRequest;
import org.elasticsearch.action.admin.indices.delete.DeleteIndexResponse;
import org.elasticsearch.action.bulk.BulkRequestBuilder;
import org.elasticsearch.action.bulk.BulkResponse;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.transport.TransportClient;
import org.elasticsearch.cluster.health.ClusterHealthStatus;
import org.elasticsearch.common.settings.Settings;
import org.elasticsearch.common.transport.TransportAddress;
import org.elasticsearch.common.xcontent.XContentType;
import org.elasticsearch.index.query.Operator;
import org.elasticsearch.index.query.QueryBuilder;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.SearchHits;
import org.elasticsearch.search.sort.SortOrder;
import org.elasticsearch.transport.client.PreBuiltTransportClient;
import com.fasterxml.jackson.databind.ObjectMapper;
//import org.eclipse.jetty.client.HttpClient;
//import org.eclipse.jetty.client.api.ContentResponse;
//import org.eclipse.jetty.client.util.StringContentProvider;
//import org.eclipse.jetty.http.HttpMethod;
//import org.eclipse.jetty.util.ssl.SslContextFactory;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
/**
 * <div align="right">
 * <p>
 * ‫کلاس های که در نام آنها SAO وجود دارد، تمام متودهای ارتباط با elasticSerach
 * را پیاده کرده است. ‫این کلاس وظیفه index کردن و جستجو در index را بر عهده
 * دارد ‫‪‫
 * </p>
 * </div>
 * 
 * @author mnoorollahi
 */
@SuppressWarnings("resource")
public class NewsSAO {
	static String clusterName= "elasticsearch";
	static String serverAddress = "localhost";
	static int serverPort = 9300;
//	private static final Logger logger = LogManager.getLogger(NewsSAO.class.getName());
	
	private static TransportClient client;
	static {
		try {
//			logger.info("connecting to Elastic server logger ...");
			System.out.println("connecting to Elastic server ...");
			
			Settings settings = Settings.builder().put("cluster.name", clusterName).build();
			client = new PreBuiltTransportClient(settings).addTransportAddress(new TransportAddress(
					InetAddress.getByName(serverAddress), serverPort));
			//logger.info("connectetd to Elastic server.");
			System.out.println("connectetd to Elastic server.");
		} catch (UnknownHostException e) {
			// TODO Auto-generated catch block
//			logger.fatal("connecting to Elastic server Faild", e);
			System.err.println("connecting to Elastic server Faild: ");
			e.printStackTrace();
			System.exit(1);
		}
	}

	public static void init() {

	}

	public static NewsServiceResult search(String query, String index_name, String type_name) {

		List<HashMap<String, String>> results = new LinkedList<HashMap<String, String>>();

//		String sortField = "pubtime";
//		SortOrder sortOrder = SortOrder.DESC;
//		TermQueryBuilder mustNotQb = termQuery("fakeField", "-1");
//		if (query.getSortField() == SortField.PUBTIME) {
//			sortField = "pubtime";
//			sortOrder = SortOrder.ASC;
//			mustNotQb = termQuery("price", "-1");
//		} else if (query.getSortField() == SortField.SCORE) {
//			sortField = "_score";
//			sortOrder = SortOrder.DESC;
//			mustNotQb = termQuery("fakeField", "-1");
//		}
//		if (query.getFrom() == null)
//			query.setFrom(0);
//		if (query.getLenght() == null)
//			query.setLenght(20);
//		String myQuery = query.getQuery().trim();
//		// String unnecessaryPartOfQuery = query.getUnnecessaryWords();
//		myQuery = myQuery.replaceAll("\\s+", " AND ");
//		// System.out.println(myQuery);
//		logger.info("logical query : " + query);
		QueryBuilder qb = QueryBuilders.queryStringQuery(query);
//		QueryBuilder qb = QueryBuilder.simple;
//		QueryBuilder qb2 =QueryBuilder
//				/**
//				 * search based on all query term. hit just documnets if all of query term
//				 * appear in one of indexed fileds
//				 */
//				//.must(QueryBuilders.matchQuery("titleNormalized", query).boost(25)).mustNot(mustNotQb);
//		/**
//		 * for manage sorting
//		 */

//		if (query.getQuery() == null || query.getQuery().trim().equals("")) {
//			qb = QueryBuilders.boolQuery();
//		}
		SearchResponse response = client.prepareSearch(index_name).setTypes(type_name).setQuery(qb).setSize(2000).
				//.setFrom(query.getFrom()).setSize(query.getLenght())//.addSort(sortField, sortOrder)
//				addSort("_score", SortOrder.DESC).
				addSort("year",SortOrder.ASC).
				addSort("month",SortOrder.ASC).
				addSort("day",SortOrder.ASC).
				addSort("hour",SortOrder.ASC).
				addSort("minute",SortOrder.ASC).
				get();
		SearchHits hits = response.getHits();
		long totalHits = hits.getTotalHits();
		if (totalHits > 0) {
			//logger.info("query is :" + query);
			System.out.println("query is :"+query);
//			logger.info("total num of hits=" + totalHits);
			System.out.println("total num of hits=" + totalHits);
			for (SearchHit hit : response.getHits().getHits()) {
//				String resultss  = hit.getSourceAsString();
				 HashMap<String, Object> currentHit = (HashMap<String, Object>) hit.getSourceAsMap();
				 HashMap<String,String> tmp = new HashMap<>();
				 for (String key :currentHit.keySet())
				 {
					 tmp.put(key, currentHit.get(key).toString());
					 tmp.put("agency-id", hit.getId());
					
				 }
				results.add(tmp);
//				System.out.println(hit.getId());
			}
			NewsServiceResult sr = new NewsServiceResult();
			sr.setResult(results);
			sr.setResultCount(totalHits);
			return sr;
		} else {
//			logger.info("no result found!");
			System.out.println("no result found");
			NewsServiceResult sr = new NewsServiceResult();
			sr.setResultCount(0);
			return sr;
			// return null;
		}
	}

	/**
	 * <div align="right"> ‫ این متود با FunctionScore اخبار را امتیازدهی میکند به
	 * این ترتیب که با وزندهی های مختلف به فیلدای مختلف خبر،اولا امتیاز را بر اساس
	 * ‫فیلدهای مهم محاسبه میکند و ثانیا با یک تابع exponential نسبت به زمان انتشار
	 * خبر واکنش نشان میدهد هرچه زمان پرسمان از زمان درج خبر فاصله بیشتری داشته باشد
	 * آن خبر امتیاز کمتری خواهد گرفت ‫چنین تابعی برای امتیاز pagerank صفحات نیز در
	 * نظر گرفته شده است </div>
	 * 
	 * @param query
	 * @param index_name
	 * @param type_name
	 * @return
	 */
//	public static NewsServiceResult searchWithFunctionScore(Query query, String index_name, String type_name) {
//		try {
//
//			String currentTime = new SimpleDateFormat("yyyyMMdd'T'HHmmss.SSSZ").format(new java.util.Date());
//			final MultiMatchQueryBuilder multiMatchQuery = QueryBuilders
//					.multiMatchQuery(query.getQuery(), "titleNormalized", "keywords^0.4", "description^0.5",
//							"contentNormalized^0.3", "aggregatedTexts^0.2")
//					.type(MultiMatchQueryBuilder.Type.BEST_FIELDS);
//
//			FilterFunctionBuilder[] functions = {
//					new FunctionScoreQueryBuilder.FilterFunctionBuilder(
//							ScoreFunctionBuilders.gaussDecayFunction("sourcePageRankScore", "0", "5")),
//					new FunctionScoreQueryBuilder.FilterFunctionBuilder(
//							exponentialDecayFunction("date", currentTime, "5d")) };
//
//			final FunctionScoreQueryBuilder functionScoreQuery = QueryBuilders.functionScoreQuery(multiMatchQuery,
//					functions);
//			functionScoreQuery.scoreMode(ScoreMode.MULTIPLY);
//
//			List<HashMap<String, Object>> results = new LinkedList<HashMap<String, Object>>();
//			SearchResponse response = client.prepareSearch(index_name).setTypes(type_name).setQuery(functionScoreQuery)
//					.get();
//			SearchHits hits = response.getHits();
//			long totalHits = hits.getTotalHits();
//			if (totalHits > 0) {
//				logger.info("query is :" + query.getQuery());
//				logger.info("total num of hits=" + totalHits);
//				for (SearchHit hit : response.getHits().getHits()) {
//					results.add((HashMap<String, Object>) hit.getSourceAsMap());
//				}
//				NewsServiceResult sr = new NewsServiceResult();
//				sr.setResult(results);
//				sr.setResultCount(totalHits);
//				return sr;
//			}
//		} catch (Exception e) {
//			logger.error("error in searchWithFunctionScore");
//			return null;
//		}
//		return null;
//	}

	public static void indexBatchDoc(List<NewsBean> newsBean, String indexName, String indexType, String DBName)
			throws Exception {
		try {
			BulkRequestBuilder bulkRequest = client.prepareBulk();
			ObjectMapper mapper = new ObjectMapper();
			if (!newsBean.isEmpty()) {
				for (NewsBean news : newsBean) {
					//NewsBean newsBean = news.getNewsBean();
//						String date = new SimpleDateFormat("yyyyMMdd'T'HHmmss.SSSZ")
//								.format(new Date(newsBean.getPubtime()));
//						FlatIndexNewsBean flatIndexNewsBean = new FlatIndexNewsBean(newsBean.getTitle(),
//								news.getTitleNormalized(), newsBean.getContent(), news.getContentNormalized(),
//								newsBean.getUrl(), newsBean.getSource(), newsBean.getPubtime(),
//								newsBean.getSourcePageRankScore(), newsBean.getDescription(), newsBean.getKeywords(),
//								news.getAggregatedTexts(), date);
					String jsonInString = mapper.writeValueAsString(news);
					bulkRequest.add(
							client.prepareIndex(indexName, indexType).setSource(jsonInString, XContentType.JSON).setId(DBName+"-"+news.getId()));
				}
				BulkResponse bulkResponse = bulkRequest.get();
				if (bulkResponse.hasFailures()) {
//					logger.error("process failures by iterating through each bulk response item");
					System.err.println("process failures by iterating through each bulk response item");
					throw new DataAccessException("index operation failed");
				} else {
					System.out.println("index batch bulk done successfully");
//					logger.info("index batch bulk done successfully");
				}

			} else
//				logger.info("null doc skipped");
			System.out.println("null doc skipped");

		} catch (Exception e) {
//			logger.error("indexBatchBulk error", e);
			System.err.println("indexBatchBulk error: "+ e);
			throw new DataAccessException("indexBatchBulk error");
		}
	}

//	public static void createIndex(String name, String type) throws Exception {
//		if (type == null)
//			type = NewsConfig.ELASTIC_NEWS_TYPE_NAME;
//		if (name == null)
//			name = NewsConfig.ELASTIC_NEWS_INDEX_NAME;
//		StringBuilder sb = new StringBuilder("");
//		sb.append("{\"settings\" : {\"number_of_shards\" : 3,\"number_of_replicas\" : 1},\"mappings\" : {\"" + type
//				+ "\" : {\"properties\" : {\n" + "		\"title_normalized\" : { \"type\" : \"text\"},\n"
//				+ "		\"title\" : {\"type\" : \"text\" , \"index\":false},\n"
//				+ "		\"content_normalized\" :{ \"type\" : \"text\" },\n"
//				+ "		\"content\" : {\"type\" : \"text\" , \"index\":false},\n"
//				+ "		\"pubtime\" :{ \"type\" : \"long\" },\n"
//				+ "		\"date\" :{ \"type\" : \"date\" , \"format\":\"basic_date_time\"},\n"
//				+ "		\"url\" : {\"type\" : \"text\" , \"index\":false},\n"
//				+ "		\"pagerank\" : {\"type\" : \"double\"},\n" + "		\"source\" : {\"type\" : \"text\"},\n"
//				+ "		\"description\" : {\"type\" : \"text\"},\n" + "		\"keywords\" : {\"type\" : \"text\"},\n"
//				+ "		\"aggregated_texts\" : {\"type\":\"text\"}\n" + "            }\n" + "        }\n" + "    }\n"
//				+ "}");
//		try {
//			String response = Utils.sendPUTRequest("http://" + NewsConfig.ELASTIC_SERVER_ADDRESS + ":9200/" + name,
//					sb.toString());
//			if (response.contains("acknowledged\":true"))
//				logger.info("index created.");
//			else
//				logger.error("create index error");
//		} catch (Exception e) {
//			logger.error("create index error", e);
//		}
//	}

	public static void deleteIndexByName(String indexName) {
		try (Scanner scan = new Scanner(System.in)) {
			System.out.print("are you sure to delete: " + indexName + "?(y/n)");
			String input = scan.nextLine();
			if (input.equals("y") || input.equals("Y")) {
				DeleteIndexResponse deleteResponse = client.admin().indices().delete(new DeleteIndexRequest(indexName))
						.actionGet();
				if (deleteResponse.isAcknowledged()) {
//					logger.info("index name:" + indexName + " deleted.");
					System.out.println("index name:" + indexName + " deleted.");
				}
			}
		} catch (Exception e) {
//			logger.error("error in delete index :", e);
			System.err.println("error in delete index :"+e);
		}

	}

//	private static void testIndex() throws Exception {
//		NewsBean newsBean = new NewsBean("url", "source", "تایتل نرمالایز نشده با نیم‌فاصله", 15151515L,
//				"کانتنت نرمالایز نشده با نیم‌فاصله", 0.54, "توضیحات", "کلمات کلیدی");
//		IndexNewsBean indexNewsBean = new IndexNewsBean(newsBean);
//		List<IndexNewsBean> list = new ArrayList<>();
//		list.add(indexNewsBean);
//		NewsSAO.indexBatchDoc(list, "news_index", "news_type");
//	}

	public static boolean isClusterOk() {
		try {
			ClusterHealthResponse healths = client.admin().cluster().prepareHealth().get();
			// String clusterName = healths.getClusterName();
			ClusterHealthStatus clusterStatus = healths.getStatus();
			if (clusterStatus.toString().equals("GREEN") || clusterStatus.toString().equals("YELLOW")) {
				return true;
			} else {
//				logger.fatal("elastic server status is red");
				System.err.println("elastic server status is red");
				
				return false;
			}
		} catch (Exception e) {
//			logger.fatal("elastic server is down",e);
			System.err.println("elastic server is down:"+e);
			return false;

		}
		// System.out.println(clusterStatus);
		// logger.info("cluster name is:" + clusterName);
		// int numberOfDataNodes = healths.getNumberOfDataNodes();
		// logger.info("number Of DataNodes is:" + numberOfDataNodes);
		// int numberOfNodes = healths.getNumberOfNodes();
		// logger.info("number Of Nodes is:" + numberOfNodes);
	}
//	public static String sendPUTRequest(String url, String json) throws Exception 
//	{
//		logger.info("sending put request "+url);
//		logger.info("json is "+json);
//		SslContextFactory sslContextFactory = new SslContextFactory();
//		HttpClient client = new HttpClient(sslContextFactory);
//		client.setFollowRedirects(true);
//		client.start();
//		ContentResponse response = client.newRequest(url).method(HttpMethod.PUT)
//				.content(new StringContentProvider(json), "application/json").send();
//		String content = response.getContentAsString();
//		client.stop();
//		return content;
//	}
	public static void main(String[] args) throws Exception {
		// deleteIndexByName("news_index");
//		if (isClusterOk())
//		{
//			System.out.println("cluster status ok");
//		}
//		else
//		{
//			System.out.println("cluster status is not ok!!!!");
//		}
		String query =  "(بن AND اسامه AND لادن)";
		  NewsServiceResult result = search(query, "news_index", "news_type");
		
		  LinkedList<HashMap<String, String>> tmp = (LinkedList<HashMap<String, String>>) result.getResult();
		  for (HashMap<String, String> hashMap : tmp) {
//			for(String key: hashMap.keySet())
//			{
//				System.out.println();
//			}
//			  System.out.println(hashMap.get(0));
			  System.out.println(hashMap.get("agency-id"));
		}
		  System.out.println("search done");
//		  for (NewsServiceResult newsResult : result.getResult()) {
//			
//		}
//		
	}

}
