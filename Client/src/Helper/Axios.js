import axios from "axios";
const axiosFetch = async ({ url, method, data = null }) => {
  //api to fetch data from postman mock server
  try {
    // axios.get("dsa", {});
    console.log("error");
    // const token = JSON.parse(sessionStorage.getItem("user") ?? "{}").token;
    const token = sessionStorage.getItem("token");
    console.log(token);
    const response = await axios.request({
      url: "http://localhost:9090/" + url,
      method,
      data: data,
      headers: {
        Authorization: token ? `Bearer ${token}` : null,
      },
    });
    return response;
  } catch (err) {
    console.error("AxiosFetch Error:", err);
    return { data: [] }; // Return empty array on error to prevent .map() failures
  }
};

export default axiosFetch;
