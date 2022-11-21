try {
    result = {
        empty: false,
        msgtype: data.notify ? 'm.text' : 'm.notice',
        plain: `${data.notify ? '@room ' : ''}${data.text}`,
        version: 'v2',
    };
} catch (error) {
    const obj = {
        error,
        data,
    };
    result = {
        empty: false,
        msgtype: 'm.text',
        plain: `\`\`\`json\n${JSON.stringify(obj, null, 4)}\n\`\`\``,
        version: 'v2',
    };
}
